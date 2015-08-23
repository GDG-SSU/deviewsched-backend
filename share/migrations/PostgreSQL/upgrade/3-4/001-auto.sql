-- Convert schema '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/3/001-auto.yml' to '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/4/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE deview_session DROP COLUMN session_num;

;

COMMIT;

