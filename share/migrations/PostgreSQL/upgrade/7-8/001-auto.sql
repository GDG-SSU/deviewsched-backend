-- Convert schema '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/7/001-auto.yml' to '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/8/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE "deview_session" (
  "year" integer NOT NULL,
  "id" integer NOT NULL,
  "day" integer NOT NULL,
  "track" integer NOT NULL,
  "title" text NOT NULL,
  "description" text NOT NULL,
  "starts_at" timestamp NOT NULL,
  "ends_at" timestamp NOT NULL,
  "target" text,
  "slide_url" text,
  "video_url" text,
  PRIMARY KEY ("year", "id")
);

;
CREATE TABLE "deview_speaker" (
  "id" serial NOT NULL,
  "session_year" integer NOT NULL,
  "session_id" integer NOT NULL,
  "name" text NOT NULL,
  "organization" text NOT NULL,
  "introduction" text NOT NULL,
  "picture" text,
  "email" text,
  "website_url" text,
  "facebook_url" text,
  "github_url" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "deview_speaker_idx_session_year_session_id" on "deview_speaker" ("session_year", "session_id");

;
CREATE TABLE "deview_user" (
  "id" bigint NOT NULL,
  "fb_token" text NOT NULL,
  "name" text NOT NULL,
  "picture" text NOT NULL,
  PRIMARY KEY ("id")
);

;
CREATE TABLE "deview_user_attendance" (
  "id" serial NOT NULL,
  "user_id" bigint NOT NULL,
  "session_year" integer NOT NULL,
  "session_day" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "deview_user_attendance_idx_user_id" on "deview_user_attendance" ("user_id");

;
CREATE TABLE "deview_user_schedule" (
  "id" serial NOT NULL,
  "user_id" bigint NOT NULL,
  "session_year" integer NOT NULL,
  "session_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "deview_user_schedule_idx_session_year_session_id" on "deview_user_schedule" ("session_year", "session_id");
CREATE INDEX "deview_user_schedule_idx_user_id" on "deview_user_schedule" ("user_id");

;
ALTER TABLE "deview_speaker" ADD CONSTRAINT "deview_speaker_fk_session_year_session_id" FOREIGN KEY ("session_year", "session_id")
  REFERENCES "deview_session" ("year", "id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "deview_user_attendance" ADD CONSTRAINT "deview_user_attendance_fk_user_id" FOREIGN KEY ("user_id")
  REFERENCES "deview_user" ("id") DEFERRABLE;

;
ALTER TABLE "deview_user_schedule" ADD CONSTRAINT "deview_user_schedule_fk_session_year_session_id" FOREIGN KEY ("session_year", "session_id")
  REFERENCES "deview_session" ("year", "id") DEFERRABLE;

;
ALTER TABLE "deview_user_schedule" ADD CONSTRAINT "deview_user_schedule_fk_user_id" FOREIGN KEY ("user_id")
  REFERENCES "deview_user" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;

COMMIT;

