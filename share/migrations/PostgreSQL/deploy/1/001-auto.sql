-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Tue Jul 28 05:32:31 2015
-- 
;
--
-- Table: deview_session
--
CREATE TABLE "deview_session" (
  "year" numeric NOT NULL,
  "id" numeric NOT NULL,
  "day" numeric NOT NULL,
  "track" numeric NOT NULL,
  "session_num" numeric NOT NULL,
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
--
-- Table: deview_speaker
--
CREATE TABLE "deview_speaker" (
  "id" serial NOT NULL,
  "session_year" numeric NOT NULL,
  "session_id" numeric NOT NULL,
  "name" text NOT NULL,
  "organization" text NOT NULL,
  "introduction" text NOT NULL,
  "picture" text NOT NULL,
  "email" text,
  "website_url" text,
  "facebook_url" text,
  "github_url" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "deview_speaker_idx_session_year_session_id" on "deview_speaker" ("session_year", "session_id");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "deview_speaker" ADD CONSTRAINT "deview_speaker_fk_session_year_session_id" FOREIGN KEY ("session_year", "session_id")
  REFERENCES "deview_session" ("year", "id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
