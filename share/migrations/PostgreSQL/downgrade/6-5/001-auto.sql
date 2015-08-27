-- Convert schema '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/6/001-auto.yml' to '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/5/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE "deview_userattendance" (
  "id" serial NOT NULL,
  "user_id" bigint NOT NULL,
  "session_year" numeric NOT NULL,
  "session_id" numeric NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "deview_userattendance_idx_session_year_session_id" on "deview_userattendance" ("session_year", "session_id");

;
ALTER TABLE "deview_userattendance" ADD CONSTRAINT "deview_userattendance_fk_session_year_session_id" FOREIGN KEY ("session_year", "session_id")
  REFERENCES "deview_session" ("year", "id") DEFERRABLE;

;
DROP TABLE deview_user_schedule CASCADE;

;

COMMIT;

