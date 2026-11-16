"""Academy operations: real DB writes and parent/teacher access restrictions."""
import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from app import User, create_app, hash_password


@pytest.fixture()
def setup(tmp_path, monkeypatch):
    monkeypatch.setenv('IQRA_COOKIE_SECURE', '0')
    url=f"sqlite:///{tmp_path/'academy.sqlite'}"
    secret='s'*48
    app=create_app(url,secret)
    return app,url,secret


def client(app):
    c=TestClient(app)
    c.get('/api/v1/session')
    return c


def post(c, url, payload=None):
    return c.post(url,json=payload or {},headers={'X-IQRA-CSRF':c.cookies.get('iqra_csrf','')})


def privileged(app,role,email):
    with app.state.db() as db:
        db.add(User(email=email,password_hash=hash_password.hash('my-long-test-passphrase-123'),role=role,active=True))
        db.commit()
    c=client(app)
    assert post(c,'/api/v1/auth/login',{'email':email,'password':'my-long-test-passphrase-123'}).status_code==200
    return c


def parent(app,email):
    c=client(app)
    assert post(c,'/api/v1/auth/register',{
        'email':email,'password':'my-long-test-passphrase-123','name':'Parent',
        'role':'parent','adult_confirmed':True}).status_code==200
    return c


def beginning(app):
    admin=privileged(app,'admin','founder@iqra.example')
    teacher=privileged(app,'teacher','teacher@iqra.example')
    stranger=privileged(app,'teacher','outsider@iqra.example')
    parent1=parent(app,'parent@iqra.example')
    parent2=parent(app,'other@iqra.example')
    kid=post(parent1,'/api/v1/profiles/child',{'name':'Amina','age_band':'6-8'}).json()['id']
    owner=post(admin,'/api/v1/admin/academies',{'name':'IQRA School'}).json()['id']
    with app.state.db() as db:
        user_id=db.query(User).filter(User.email=='teacher@iqra.example').one().id
    course=post(admin,'/api/v1/admin/classes',{'title':'Alif to Jim','academy_id':owner,'teacher_id':user_id}).json()['id']
    return admin,teacher,stranger,parent1,parent2,kid,owner,course


def test_learner_teacher_parent_and_admin_journey(setup):
    app,url,secret=setup
    admin,teacher,outsider,p1,p2,kid,academy,cls=beginning(app)
    assert post(p1,f'/api/v1/academy/classes/{cls}/enroll',{'profile_id':kid}).status_code==200
    assert post(p1,f'/api/v1/academy/classes/{cls}/enroll',{'profile_id':kid}).status_code==409
    task=post(teacher,f'/api/v1/academy/classes/{cls}/assignments',{
        'title':'Recognize Alif','max_score':10,'instructions':'Name the letter'}).json()['id']
    ans=post(p1,f'/api/v1/academy/assignments/{task}/submit',{
        'profile_id':kid,'answer':'Alif'}).json()['id']
    assert post(p1,f'/api/v1/academy/assignments/{task}/submit',{'profile_id':kid,'answer':'Again'}).status_code==409
    assert post(teacher,f'/api/v1/academy/submissions/{ans}/grade',{'score':11}).status_code==422
    assert post(teacher,f'/api/v1/academy/submissions/{ans}/grade',{'score':9,'feedback':'Well done'}).status_code==200
    day={'profile_id':kid,'day':'2026-11-16','status':'present'}
    assert post(teacher,f'/api/v1/academy/classes/{cls}/attendance',day).status_code==200
    assert post(teacher,f'/api/v1/academy/classes/{cls}/attendance',{**day,'status':'late'}).status_code==200
    fresh=TestClient(create_app(url,secret))
    fresh.get('/api/v1/session')
    assert post(fresh,'/api/v1/auth/login',{'email':'parent@iqra.example','password':'my-long-test-passphrase-123'}).status_code==200
    r=fresh.get(f'/api/v1/academy/classes/{cls}/progress?profile_id={kid}')
    assert r.status_code==200,r.text
    assert r.json()['assignments'][0]['score']==9
    assert r.json()['attendance'][0]['status']=='late'
    stats=admin.get(f'/api/v1/admin/academies/{academy}/summary').json()
    assert stats=={'classes':1,'enrollments':1,'submissions':1}
    assert p2.get(f'/api/v1/academy/classes/{cls}/progress?profile_id={kid}').status_code==404
    assert outsider.get(f'/api/v1/academy/classes/{cls}/progress?profile_id={kid}').status_code==403
    assert post(outsider,f'/api/v1/academy/classes/{cls}/assignments',{'title':'Unauthorized','max_score':10}).status_code==403
    assert post(outsider,f'/api/v1/academy/submissions/{ans}/grade',{'score':5}).status_code==403
    assert post(outsider,f'/api/v1/academy/classes/{cls}/attendance',day).status_code==403


def test_bad_roles_and_csrf(setup):
    app,_,_=setup
    admin,teacher,outsider,p1,p2,kid,academy,cls=beginning(app)
    assert p1.get(f'/api/v1/admin/academies/{academy}/summary').status_code==403
    assert p1.post(f'/api/v1/academy/classes/{cls}/enroll',json={'profile_id':kid}).status_code==403
    assert post(teacher,'/api/v1/admin/classes',{'title':'Fail','academy_id':academy,'teacher_id':1}).status_code==403
    assert post(p2,f'/api/v1/academy/classes/{cls}/enroll',{'profile_id':kid}).status_code==404
    assert client(app).get(f'/api/v1/academy/classes/{cls}/progress?profile_id={kid}').status_code==401
    assert post(teacher,f'/api/v1/academy/classes/{cls}/attendance',{'profile_id':kid,'day':'2026-99-99','status':'present'}).status_code in (403,422)
