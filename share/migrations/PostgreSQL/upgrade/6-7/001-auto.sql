-- Convert schema '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/6/001-auto.yml' to '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/7/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE "deview_user_attendance" (
  "id" serial NOT NULL,
  "user_id" bigint NOT NULL,
  "session_year" numeric NOT NULL,
  "session_day" numeric NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "deview_user_attendance_idx_user_id" on "deview_user_attendance" ("user_id");

;
ALTER TABLE "deview_user_attendance" ADD CONSTRAINT "deview_user_attendance_fk_user_id" FOREIGN KEY ("user_id")
  REFERENCES "deview_user" ("id") DEFERRABLE;

;

COMMIT;

