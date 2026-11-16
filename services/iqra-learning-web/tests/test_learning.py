import secrets
import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import select

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from app import User, Lesson, create_app, hash_password


@pytest.fixture()
def env(tmp_path, monkeypatch):
    monkeypatch.setenv("IQRA_COOKIE_SECURE", "0")
    url = f"sqlite:///{tmp_path / 'learning.sqlite'}"
    secret = "t" * 48
    app = create_app(url, secret)
    return app, url, secret


def client(app):
    c = TestClient(app)
    c.get("/api/v1/session")
    return c


def post(c, path, data=None):
    return c.post(path, json=data or {}, headers={"X-IQRA-CSRF": c.cookies.get("iqra_csrf", "")})


def put(c, path, data=None):
    return c.put(path, json=data or {}, headers={"X-IQRA-CSRF": c.cookies.get("iqra_csrf", "")})


def register(c, email, role="adult"):
    r = post(c, "/api/v1/auth/register", {
        "email": email, "password": "proper-long-passphrase-123", "role": role, "name": "Learning Person", "adult_confirmed": True
    })
    assert r.status_code == 200, r.text


def privileged(app, role, email):
    with app.state.db() as db:
        db.add(User(email=email, password_hash=hash_password.hash("proper-long-passphrase-123"), role=role))
        db.commit()
    c = client(app)
    assert post(c, "/api/v1/auth/login", {"email": email, "password": "proper-long-passphrase-123"}).status_code == 200
    return c


def publish(app, track="adult"):
    reviewer = privileged(app, "reviewer", f"reviewer-{track}@test.test")
    admin = privileged(app, "admin", f"admin-{track}@test.test")
    r = admin.get("/api/v1/admin/lessons")
    target = next(x for x in r.json() if x["track"] == track)
    assert post(reviewer, f"/api/v1/admin/lessons/{target['id']}/review").status_code == 200
    assert post(admin, f"/api/v1/admin/lessons/{target['id']}/publish").status_code == 200
    return target["id"], reviewer, admin


def test_privacy_csrf_and_login(env):
    app, _, _ = env
    a, b = client(app), client(app)
    assert a.post("/api/v1/auth/register", json={"email":"a@test.test","password":"proper-long-passphrase-123","name":"A"}).status_code == 403
    register(a, "a@test.test", "parent")
    register(b, "b@test.test")
    child = post(a, "/api/v1/profiles/child", {"name":"Child A", "age_band":"6-8"})
    assert child.status_code == 200
    id_ = child.json()["id"]
    assert b.get(f"/api/v1/learning/lessons?profile_id={id_}").status_code == 404
    assert post(b, "/api/v1/profiles/child", {"name":"Not a parent", "age_band":"6-8"}).status_code == 403
    assert a.get("/api/v1/admin/lessons").status_code == 403
    assert post(a, "/api/v1/auth/logout").status_code == 200
    assert a.get("/api/v1/profiles").status_code == 401


def test_publish_gate_progress_idempotency_and_persistence(env):
    app, url, secret = env
    adult = client(app)
    register(adult, "learner@test.test")
    profile = adult.get("/api/v1/profiles").json()[0]
    assert adult.get(f"/api/v1/learning/lessons?profile_id={profile['id']}").json()["lessons"] == []
    lesson_id, reviewer, admin = publish(app)
    result = adult.get(f"/api/v1/learning/lessons?profile_id={profile['id']}").json()["lessons"][0]
    assert result["unlocked"] is True
    assert "answer_index" not in result
    assert result["completed"] is False
    payload = {"event_id": "test-event-long-00001", "profile_id": profile["id"], "lesson_id": lesson_id, "selected_index": 0}
    first = post(adult, "/api/v1/learning/answer", payload)
    assert first.status_code == 200 and first.json() == {"ok": True, "correct": True, "replayed": False}
    second = post(adult, "/api/v1/learning/answer", payload)
    assert second.status_code == 200 and second.json()["replayed"] is True
    changed = {**payload, "selected_index": 1}
    assert post(adult, "/api/v1/learning/answer", changed).status_code == 409
    fresh_app = create_app(url, secret)
    new_device = client(fresh_app)
    assert post(new_device, "/api/v1/auth/login", {"email":"learner@test.test","password":"proper-long-passphrase-123"}).status_code == 200
    lessons = new_device.get(f"/api/v1/learning/lessons?profile_id={profile['id']}").json()["lessons"]
    assert lessons[0]["completed"] is True
    update = {"title":"Revised Fatiha lesson", "description":"Reviewed introductory lesson for adult learners", "source_ref":"Qur'an 1:1-7", "prompt":"Which surah?", "options":["Al-Fatiha","Al-Ikhlas"], "answer_index":0}
    r = put(admin, f"/api/v1/admin/lessons/{lesson_id}", update)
    assert r.status_code == 200 and r.json()["state"] == "draft"
    assert new_device.get(f"/api/v1/learning/lessons?profile_id={profile['id']}").json()["lessons"] == []
    assert post(admin, f"/api/v1/admin/lessons/{lesson_id}/publish").status_code == 409
    assert post(reviewer, f"/api/v1/admin/lessons/{lesson_id}/review").status_code == 200
    assert post(admin, f"/api/v1/admin/lessons/{lesson_id}/publish").status_code == 200
    after = new_device.get(f"/api/v1/learning/lessons?profile_id={profile['id']}").json()["lessons"][0]
    assert after["version"] == 2 and after["completed"] is False


def test_kids_separate_parent_scope_and_lesson_sequence(env):
    app, _, _ = env
    parent = client(app)
    register(parent, "parent@test.test", "parent")
    kid_id = post(parent, "/api/v1/profiles/child", {"name":"Kid", "age_band":"9-12"}).json()["id"]
    _, reviewer, admin = publish(app, "kids")
    lessons = parent.get(f"/api/v1/learning/lessons?profile_id={kid_id}").json()["lessons"]
    assert len(lessons) == 1 and lessons[0]["track"] == "kids"
    first = lessons[0]
    assert post(parent, "/api/v1/learning/answer", {"event_id":"kids-event-abc001", "profile_id":kid_id, "lesson_id":first["id"], "selected_index":1}).json()["correct"] is False
    assert post(parent, "/api/v1/learning/answer", {"event_id":"kids-event-abc002", "profile_id":kid_id, "lesson_id":first["id"], "selected_index":0}).json()["correct"] is True
    adult = client(app)
    register(adult, "notparent@test.test")
    assert adult.get(f"/api/v1/learning/lessons?profile_id={kid_id}").status_code == 404
    assert post(adult, "/api/v1/learning/answer", {"event_id":"wrong-family-event", "profile_id":kid_id, "lesson_id":first["id"], "selected_index":0}).status_code == 404


def test_security_headers_and_admin_role(env):
    app, _, _ = env
    c = client(app)
    r = c.get("/")
    assert r.status_code == 200 and "IQRA" in r.text
    assert "frame-ancestors 'none'" in r.headers["content-security-policy"]
    assert c.get("/api/v1/health").json()["database"] == "reachable"
    assert c.get("/api/v1/admin/lessons").status_code == 401