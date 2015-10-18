-- Convert schema '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/8/001-auto.yml' to '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/7/001-auto.yml':;

;
BEGIN;

;
DROP TABLE deview_session CASCADE;

;
DROP TABLE deview_user CASCADE;

;
DROP TABLE deview_speaker CASCADE;

;
DROP TABLE deview_user_attendance CASCADE;

;
DROP TABLE deview_user_schedule CASCADE;

;

COMMIT;

