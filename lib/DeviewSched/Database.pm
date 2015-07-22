package DeviewSched::Database;
use 5.010;
use utf8;
use strict;
use warnings;

use DBI;
use DBD::Pg;

require Exporter;

our @ISA       = qw/Exporter/;
our @EXPORT_OK = qw/get_dbh/;

sub SQL_DB_INIT () { return <<SQL_DB_INIT

    CREATE TABLE DeviewSession (
        year            NUMERIC     NOT NULL,
        id              NUMERIC     NOT NULL,

        day             NUMERIC     NOT NULL,
        track           NUMERIC     NOT NULL,
        session_num     NUMERIC     NOT NULL,
        title           TEXT        NOT NULL,
        description     TEXT        NOT NULL,

        starts_at       TIMESTAMP   NOT NULL,
        ends_at         TIMESTAMP   NOT NULL,

        target          TEXT,
        slide_url       TEXT,
        video_url       TEXT,

        PRIMARY KEY (year, id)
    );

    CREATE TABLE DeviewSpeaker (
        id              SERIAL  NOT NULL,
        session_year    NUMERIC NOT NULL,
        session_id      NUMERIC NOT NULL,

        name            TEXT    NOT NULL,
        organization    TEXT    NOT NULL,
        introduction    TEXT    NOT NULL,
        picture         TEXT    NOT NULL,

        email           TEXT,
        website         TEXT,

        PRIMARY KEY (id),
        FOREIGN KEY (session_year, session_id) REFERENCES DeviewSession(year, id)
    );

SQL_DB_INIT
}

sub SQL_DROP_TABLES { 
    sprintf "DROP TABLE %s;", join(", ", @_);
}

sub DB_DEFAULT_ATTRIBUTES () {{
    AutoCommit => 0,
    RaiseError => 1,
    pg_enable_utf8 => 1,
}}

sub generate_dsn {
    my $db_config = shift;
    return sprintf "dbi:Pg:dbname=%s;host=%s;port=%d",
        $db_config->{database},
        $db_config->{host},
        $db_config->{port};
}

sub get_dbh {
    my $db_config = shift;
    my $dbh = DBI->connect(generate_dsn($db_config),
        $db_config->{username}, $db_config->{password},
        DB_DEFAULT_ATTRIBUTES
    );

    return $dbh;
}

1;
