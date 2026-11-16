"""IQRA website-first learning vertical. No sample users or live deployment."""
from __future__ import annotations

import getpass
import os
import secrets
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Literal

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError, VerificationError
from fastapi import Depends, FastAPI, HTTPException, Request, Response
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field
from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, UniqueConstraint, create_engine, select
from sqlalchemy.orm import DeclarativeBase, Mapped, Session, mapped_column, relationship, sessionmaker
from sqlalchemy.types import JSON


class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "iqra_users"
    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    role: Mapped[str] = mapped_column(String(30))
    active: Mapped[bool] = mapped_column(Boolean, default=True)


class Profile(Base):
    __tablename__ = "iqra_profiles"
    id: Mapped[int] = mapped_column(primary_key=True)
    owner_id: Mapped[int] = mapped_column(ForeignKey("iqra_users.id"), index=True)
    name: Mapped[str] = mapped_column(String(100))
    kind: Mapped[str] = mapped_column(String(20))
    age_band: Mapped[str | None] = mapped_column(String(10), nullable=True)


class Lesson(Base):
    __tablename__ = "iqra_lessons"
    id: Mapped[int] = mapped_column(primary_key=True)
    slug: Mapped[str] = mapped_column(String(100), unique=True)
    track: Mapped[str] = mapped_column(String(30))
    ordinal: Mapped[int] = mapped_column(Integer)
    title: Mapped[str] = mapped_column(String(180))
    description: Mapped[str] = mapped_column(String(1500))
    source_ref: Mapped[str] = mapped_column(String(100), default="")
    prompt: Mapped[str] = mapped_column(String(350))
    options: Mapped[list] = mapped_column(JSON)
    answer_index: Mapped[int] = mapped_column(Integer)
    state: Mapped[str] = mapped_column(String(20), default="draft")
    version: Mapped[int] = mapped_column(Integer, default=1)
    reviewed_by: Mapped[int | None] = mapped_column(ForeignKey("iqra_users.id"), nullable=True)
    published_by: Mapped[int | None] = mapped_column(ForeignKey("iqra_users.id"), nullable=True)


class Attempt(Base):
    __tablename__ = "iqra_learning_attempts"
    id: Mapped[int] = mapped_column(primary_key=True)
    event_id: Mapped[str] = mapped_column(String(100))
    profile_id: Mapped[int] = mapped_column(ForeignKey("iqra_profiles.id"), index=True)
    lesson_id: Mapped[int] = mapped_column(ForeignKey("iqra_lessons.id"))
    lesson_version: Mapped[int] = mapped_column(Integer)
    selected_index: Mapped[int] = mapped_column(Integer)
    correct: Mapped[bool] = mapped_column(Boolean)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    __table_args__ = (UniqueConstraint("profile_id", "event_id", name="uq_iqra_progress_event"),)


hash_password = PasswordHasher()


class Registration(BaseModel):
    email: str = Field(min_length=5, max_length=255)
    password: str = Field(min_length=12, max_length=128)
    name: str = Field(min_length=1, max_length=100)
    role: Literal["adult", "parent"] = "adult"
    adult_confirmed: bool = False


class Credentials(BaseModel):
    email: str
    password: str


class ChildCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    age_band: Literal["6-8", "9-12"]


class SubmitAnswer(BaseModel):
    event_id: str = Field(min_length=12, max_length=100)
    profile_id: int
    lesson_id: int
    selected_index: int = Field(ge=0, le=10)


class LessonUpdate(BaseModel):
    title: str = Field(min_length=3, max_length=180)
    description: str = Field(min_length=10, max_length=1500)
    source_ref: str = Field(min_length=1, max_length=100)
    prompt: str = Field(min_length=3, max_length=350)
    options: list[str] = Field(min_length=2, max_length=5)
    answer_index: int = Field(ge=0, le=4)


def _email(value: str) -> str:
    email = value.strip().lower()
    if "@" not in email or len(email) > 255:
        raise HTTPException(422, "Enter a valid email address")
    return email


def _public_lesson(lesson: Lesson) -> dict:
    return {"id": lesson.id, "slug": lesson.slug, "track": lesson.track,
            "title": lesson.title, "description": lesson.description,
            "source_ref": lesson.source_ref, "prompt": lesson.prompt,
            "options": lesson.options, "version": lesson.version, "state": lesson.state}


def _seed(db: Session) -> None:
    # Educational content is draft until a qualified reviewer approves and admin publishes it.
    rows = [
        ("fatiha-intro", "adult", 1, "Meet Surah Al-Fatiha", "Explore its place in the Qur'an and why it appears in daily prayer.", "Qur'an 1:1-7", "Which surah is this pathway about?", ["Al-Fatiha", "Al-Ikhlas", "Al-Falaq"], 0),
        ("fatiha-ayah-1", "adult", 2, "Study verse 1", "Read verse 1 from an approved Mushaf and listen to a licensed recitation before responding.", "Qur'an 1:1", "What should you consult to verify the verse?", ["An approved Qur'an source", "An anonymous social post"], 0),
        ("fatiha-ayah-2", "adult", 3, "Study verse 2", "Compare a reviewed translation with an approved recitation of verse 2.", "Qur'an 1:2", "Which source should guide a translation?", ["A reviewed translation", "An unverified caption"], 0),
        ("fatiha-ayah-3", "adult", 4, "Study verse 3", "Practice verse 3 with a trusted teacher or verified recitation.", "Qur'an 1:3", "Who can provide qualified recitation feedback?", ["A verified teacher", "An unreviewed AI guess"], 0),
        ("fatiha-review", "adult", 5, "Review and reflect", "Practice the complete seven-verse surah. Recitation assessment remains teacher-reviewed.", "Qur'an 1:1-7", "How many verses are in Surah Al-Fatiha in the standard numbering?", ["Seven", "Three", "Ten"], 0),
        ("arabic-alif", "kids", 1, "Meet Alif", "Learn to recognize the letter Alif. Ask a parent or teacher to sound it out with you.", "Arabic alphabet", "Tap Alif", ["ا", "ب", "ت"], 0),
        ("arabic-ba", "kids", 2, "Meet Ba", "Look for the single dot below the letter Ba.", "Arabic alphabet", "Tap Ba", ["ا", "ب", "ج"], 1),
        ("arabic-ta", "kids", 3, "Meet Ta", "Find the letter with two dots above.", "Arabic alphabet", "Tap Ta", ["ث", "ت", "ب"], 1),
        ("arabic-tha", "kids", 4, "Meet Tha", "Find the letter with three dots above.", "Arabic alphabet", "Tap Tha", ["ت", "ب", "ث"], 2),
        ("arabic-jim", "kids", 5, "Meet Jim", "Find the letter with a dot inside/below the curve.", "Arabic alphabet", "Tap Jim", ["ح", "ج", "خ"], 1),
    ]
    existing = set(db.scalars(select(Lesson.slug)).all())
    for slug, track, ordinal, title, desc, source, prompt, options, answer in rows:
        if slug not in existing:
            db.add(Lesson(slug=slug, track=track, ordinal=ordinal, title=title,
                          description=desc, source_ref=source, prompt=prompt, options=options,
                          answer_index=answer, state="draft", version=1))
    db.commit()


def create_app(database_url: str | None = None, secret: str | None = None) -> FastAPI:
    database_url = database_url or os.environ.get("IQRA_DATABASE_URL", "")
    secret = secret or os.environ.get("IQRA_SESSION_SECRET", "")
    if not database_url or len(secret) < 32:
        raise RuntimeError("Configure IQRA_DATABASE_URL and IQRA_SESSION_SECRET (32+ characters)")
    if os.environ.get("IQRA_ENV") == "production":
        raise RuntimeError("Production release is blocked until migrations, audit logging, rate limits, legal review and a verified deployment gate")
    engine = create_engine(database_url, connect_args={"check_same_thread": False} if database_url.startswith("sqlite") else {}, pool_pre_ping=True)
    Base.metadata.create_all(engine)  # Staging/bootstrap only. Introduce reviewed migrations before production.
    SessionLocal = sessionmaker(bind=engine, expire_on_commit=False)
    with SessionLocal() as db:
        _seed(db)
    app = FastAPI(title="IQRA Website Learning Service", docs_url=None, redoc_url=None)
    app.mount("/assets", StaticFiles(directory=Path(__file__).parent / "static"), name="assets")

    @app.middleware("http")
    async def security_headers(request: Request, call_next):
        response = await call_next(request)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["Referrer-Policy"] = "no-referrer"
        response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; object-src 'none'; base-uri 'none'; frame-ancestors 'none'"
        return response
    app.state.db = SessionLocal
    app.state.secret = secret
    secure = os.environ.get("IQRA_COOKIE_SECURE", "1") != "0"

    def db_dep():
        with SessionLocal() as db:
            yield db

    def require_csrf(request: Request):
        cookie = request.cookies.get("iqra_csrf")
        header = request.headers.get("X-IQRA-CSRF")
        if not cookie or not header or not secrets.compare_digest(cookie, header):
            raise HTTPException(403, "Security token missing. Reload and try again.")
        origin = request.headers.get("origin")
        if origin and origin != str(request.base_url).rstrip("/"):
            raise HTTPException(403, "Cross-origin changes are not allowed")

    def current_user(request: Request, db: Session = Depends(db_dep)) -> User:
        token = request.cookies.get("iqra_session")
        if not token:
            raise HTTPException(401, "Please sign in")
        try:
            data = jwt.decode(token, secret, algorithms=["HS256"])
            user = db.get(User, int(data["sub"]))
        except (jwt.PyJWTError, ValueError, TypeError):
            raise HTTPException(401, "Session expired")
        if not user or not user.active:
            raise HTTPException(401, "Account unavailable")
        return user

    def require_role(user: User, *roles: str):
        if user.role not in roles:
            raise HTTPException(403, "Your role cannot perform this action")

    def owned_profile(db: Session, user: User, profile_id: int) -> Profile:
        profile = db.get(Profile, profile_id)
        if not profile or profile.owner_id != user.id:
            raise HTTPException(404, "Learning profile not found")
        return profile

    @app.get("/")
    def home():
        return FileResponse(Path(__file__).parent / "static" / "index.html", media_type="text/html")

    @app.get("/api/v1/health")
    def health(db: Session = Depends(db_dep)):
        db.execute(select(User.id).limit(1))
        return {"ok": True, "service": "iqra-learning-web", "database": "reachable"}

    @app.get("/api/v1/session")
    def session_info(response: Response, request: Request, db: Session = Depends(db_dep)):
        csrf = request.cookies.get("iqra_csrf") or secrets.token_urlsafe(32)
        response.set_cookie("iqra_csrf", csrf, httponly=False, secure=secure, samesite="strict", path="/")
        try:
            user = current_user(request, db)
        except HTTPException:
            user = None
        return {"signed_in": bool(user), "email": user.email if user else None,
                "role": user.role if user else None}

    @app.post("/api/v1/auth/register", dependencies=[Depends(require_csrf)])
    def register(payload: Registration, response: Response, db: Session = Depends(db_dep)):
        if not payload.adult_confirmed:
            raise HTTPException(422, "This account requires an adult. Children use parent-managed profiles.")
        email = _email(payload.email)
        if db.scalar(select(User.id).where(User.email == email)):
            raise HTTPException(409, "Email already registered")
        user = User(email=email, password_hash=hash_password.hash(payload.password), role=payload.role, active=True)
        db.add(user)
        db.flush()
        db.add(Profile(owner_id=user.id, name=payload.name.strip(), kind="adult"))
        db.commit()
        set_session(response, user)
        return {"ok": True, "role": user.role}

    def set_session(response: Response, user: User):
        token = jwt.encode({"sub": str(user.id), "exp": datetime.now(timezone.utc) + timedelta(hours=12)}, secret, algorithm="HS256")
        response.set_cookie("iqra_session", token, httponly=True, secure=secure, samesite="strict", max_age=43200, path="/")

    @app.post("/api/v1/auth/login", dependencies=[Depends(require_csrf)])
    def login(payload: Credentials, response: Response, db: Session = Depends(db_dep)):
        user = db.scalar(select(User).where(User.email == _email(payload.email)))
        try:
            if not user or not user.active or not hash_password.verify(user.password_hash, payload.password):
                raise HTTPException(401, "Invalid login")
        except (VerifyMismatchError, VerificationError):
            raise HTTPException(401, "Invalid login")
        set_session(response, user)
        return {"ok": True, "role": user.role}

    @app.post("/api/v1/auth/logout", dependencies=[Depends(require_csrf)])
    def logout(response: Response):
        response.delete_cookie("iqra_session", path="/")
        return {"ok": True}

    @app.get("/api/v1/profiles")
    def profiles(user: User = Depends(current_user), db: Session = Depends(db_dep)):
        return [{"id": p.id, "name": p.name, "kind": p.kind, "age_band": p.age_band}
                for p in db.scalars(select(Profile).where(Profile.owner_id == user.id)).all()]

    @app.post("/api/v1/profiles/child", dependencies=[Depends(require_csrf)])
    def create_child(payload: ChildCreate, user: User = Depends(current_user), db: Session = Depends(db_dep)):
        require_role(user, "parent")
        profile = Profile(owner_id=user.id, name=payload.name.strip(), kind="kids", age_band=payload.age_band)
        db.add(profile)
        db.commit()
        return {"id": profile.id, "name": profile.name}

    @app.get("/api/v1/learning/lessons")
    def lessons(profile_id: int, user: User = Depends(current_user), db: Session = Depends(db_dep)):
        profile = owned_profile(db, user, profile_id)
        track = "kids" if profile.kind == "kids" else "adult"
        lessons = db.scalars(select(Lesson).where(Lesson.track == track, Lesson.state == "published").order_by(Lesson.ordinal)).all()
        passed = set(db.execute(select(Attempt.lesson_id, Attempt.lesson_version).where(
            Attempt.profile_id == profile.id, Attempt.correct == True)).all())
        items = []
        previous_completed = True
        for lesson in lessons:
            completed = (lesson.id, lesson.version) in passed
            items.append({**_public_lesson(lesson), "completed": completed, "unlocked": previous_completed})
            previous_completed = completed
        return {"profile": {"id": profile.id, "name": profile.name}, "lessons": items}

    @app.post("/api/v1/learning/answer", dependencies=[Depends(require_csrf)])
    def answer(payload: SubmitAnswer, user: User = Depends(current_user), db: Session = Depends(db_dep)):
        profile = owned_profile(db, user, payload.profile_id)
        previous = db.scalar(select(Attempt).where(Attempt.profile_id == profile.id, Attempt.event_id == payload.event_id))
        if previous:
            if previous.lesson_id != payload.lesson_id or previous.selected_index != payload.selected_index:
                raise HTTPException(409, "An event ID was reused for a different answer")
            return {"ok": True, "correct": previous.correct, "replayed": True}
        lesson = db.get(Lesson, payload.lesson_id)
        track = "kids" if profile.kind == "kids" else "adult"
        if not lesson or lesson.state != "published" or lesson.track != track:
            raise HTTPException(404, "Published lesson not found")
        if payload.selected_index >= len(lesson.options):
            raise HTTPException(422, "Invalid answer")
        prior_lessons = db.scalars(select(Lesson).where(
            Lesson.track == track, Lesson.state == "published", Lesson.ordinal < lesson.ordinal)).all()
        for prior in prior_lessons:
            prior_passed = db.scalar(select(Attempt.id).where(
                Attempt.profile_id == profile.id, Attempt.lesson_id == prior.id,
                Attempt.lesson_version == prior.version, Attempt.correct == True))
            if not prior_passed:
                raise HTTPException(409, "Complete the previous lesson first")
        correct = payload.selected_index == lesson.answer_index
        db.add(Attempt(event_id=payload.event_id, profile_id=profile.id, lesson_id=lesson.id,
                       lesson_version=lesson.version, selected_index=payload.selected_index, correct=correct))
        db.commit()
        return {"ok": True, "correct": correct, "replayed": False}

    @app.get("/api/v1/admin/lessons")
    def admin_lessons(user: User = Depends(current_user), db: Session = Depends(db_dep)):
        require_role(user, "admin", "reviewer")
        rows = db.scalars(select(Lesson).order_by(Lesson.track, Lesson.ordinal)).all()
        return [{**_public_lesson(l), "reviewed_by": l.reviewed_by} for l in rows]

    @app.put("/api/v1/admin/lessons/{lesson_id}", dependencies=[Depends(require_csrf)])
    def edit_lesson(lesson_id: int, data: LessonUpdate, user: User = Depends(current_user), db: Session = Depends(db_dep)):
        require_role(user, "admin")
        lesson = db.get(Lesson, lesson_id)
        if not lesson:
            raise HTTPException(404, "Lesson not found")
        if data.answer_index >= len(data.options):
            raise HTTPException(422, "Answer must be in options")
        lesson.title, lesson.description, lesson.source_ref = data.title, data.description, data.source_ref
        lesson.prompt, lesson.options, lesson.answer_index = data.prompt, data.options, data.answer_index
        lesson.version += 1
        lesson.state, lesson.reviewed_by, lesson.published_by = "draft", None, None
        db.commit()
        return {"ok": True, "state": lesson.state, "version": lesson.version}

    @app.post("/api/v1/admin/lessons/{lesson_id}/review", dependencies=[Depends(require_csrf)])
    def review_lesson(lesson_id: int, user: User = Depends(current_user), db: Session = Depends(db_dep)):
        require_role(user, "reviewer")
        lesson = db.get(Lesson, lesson_id)
        if not lesson or lesson.state != "draft":
            raise HTTPException(409, "Only draft lessons can be reviewed")
        lesson.state, lesson.reviewed_by = "reviewed", user.id
        db.commit()
        return {"ok": True, "state": "reviewed"}

    @app.post("/api/v1/admin/lessons/{lesson_id}/publish", dependencies=[Depends(require_csrf)])
    def publish_lesson(lesson_id: int, user: User = Depends(current_user), db: Session = Depends(db_dep)):
        require_role(user, "admin")
        lesson = db.get(Lesson, lesson_id)
        if not lesson or lesson.state != "reviewed" or not lesson.reviewed_by:
            raise HTTPException(409, "A qualified reviewer must review this lesson first")
        lesson.state, lesson.published_by = "published", user.id
        db.commit()
        return {"ok": True, "state": "published"}

    return app


if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] not in ("bootstrap-admin", "bootstrap-reviewer"):
        raise SystemExit("Usage: python app.py bootstrap-admin|bootstrap-reviewer email@example.com")
    make = create_app()
    role = "admin" if sys.argv[1] == "bootstrap-admin" else "reviewer"
    email = _email(sys.argv[2])
    pw = getpass.getpass("New password (12+ characters): ")
    if len(pw) < 12:
        raise SystemExit("Password must have 12+ characters")
    with make.state.db() as db:
        if db.scalar(select(User.id).where(User.email == email)):
            raise SystemExit("Account already exists")
        db.add(User(email=email, password_hash=hash_password.hash(pw), role=role, active=True))
        db.commit()
    print(f"Created {role} account {email}")