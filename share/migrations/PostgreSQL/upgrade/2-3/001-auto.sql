-- Convert schema '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/2/001-auto.yml' to '/home/cheesekun/works/deviewsched-backend/share/migrations/_source/deploy/3/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE deview_user ADD COLUMN fb_token text NOT NULL;

;

COMMIT;

