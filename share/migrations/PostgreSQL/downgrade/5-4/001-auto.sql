-- Convert schema '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/5/001-auto.yml' to '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/4/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE deview_speaker ALTER COLUMN picture SET NOT NULL;

;

COMMIT;

