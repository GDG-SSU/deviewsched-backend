-- Convert schema '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/5/001-auto.yml' to '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/6/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE "deview_user_schedule" (
  "id" serial NOT NULL,
  "user_id" bigint NOT NULL,
  "session_year" numeric NOT NULL,
  "session_id" numeric NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "deview_user_schedule_idx_session_year_session_id" on "deview_user_schedule" ("session_year", "session_id");
CREATE INDEX "deview_user_schedule_idx_user_id" on "deview_user_schedule" ("user_id");

;
ALTER TABLE "deview_user_schedule" ADD CONSTRAINT "deview_user_schedule_fk_session_year_session_id" FOREIGN KEY ("session_year", "session_id")
  REFERENCES "deview_session" ("year", "id") DEFERRABLE;

;
ALTER TABLE "deview_user_schedule" ADD CONSTRAINT "deview_user_schedule_fk_user_id" FOREIGN KEY ("user_id")
  REFERENCES "deview_user" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
DROP TABLE deview_userattendance CASCADE;

;

COMMIT;

