package DeviewSched::Database;
use 5.010;
use utf8;
use strict;
use warnings;

use DBI;
use DBD::Pg;

use DeviewSched::Schema;

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
    AutoCommit => 1,
    RaiseError => 1,
    pg_enable_utf8 => 1,
}}

sub generate_dsn {
    my $db_config = shift;
    return sprintf(
        "dbi:Pg:dbname=%s;host=%s;port=%d",
        $db_config->{database},
        $db_config->{host},
        $db_config->{port}
    );
}

sub get_dbh {
    my $db_config = shift;
    my $get_as_orm_schema = shift || 0;

    my $base_class = ($get_as_orm_schema) ? 'DeviewSched::Schema' : 'DBI';

    my $dbh = $base_class->connect(generate_dsn($db_config),
        $db_config->{username}, $db_config->{password},
        DB_DEFAULT_ATTRIBUTES
    );

    return $dbh;
}


1;
__END__

=encoding utf8

=head1 NAME

DeviewSched::Database - 데이터베이스 접근에 관련된 모듈

=head1 SYNOPSIS

    use Mojolicious::Lite;
    use DeviewSched::ConfigHelper;
    use DeviewSched::Database qw/get_dbh/;
    
    load_config_from_outside(app);
    
    my $db_config = app->config->{database};
    my $dbh = get_dbh($db_config); 
    
    # OMGWTF!
    $dbh->prepare(generate_sql(DROP_ALL_TABLES))->execute;

    # or ..
    
    my $schema = get_dbh($db_config, 1);
    my $rs = $schema->result_set( ... );


=head1 DESCRIPTION

DeviewSched::Database는 데이터베이스와 관련된 모듈입니다. DB에 접근하기 위한 핸들 (DBH, DBIx::Class::Schema) 등을 쉽게 취득할 수 있도록 돕습니다. 

=head2 CONSTANTS

=over 4

=item C<SQL_DB_INIT>

데이터베이스 초기화 SQL 쿼리문

=item C<SQL_DROP_TABLES(@tables)>

테이블 드랍 SQL 쿼리문

=back

=head2 METHODS

=over 4 

=item C<generate_dsn($config)>

설정 정보를 기반으로 DSN을 생성합니다.

=item C<get_dbh($config, $get_as_dbix_schema)>

DB에 접속하고 DB 핸들을 취득합니다.
C<$get_as_dbix_schema>가 설정되어 있으면, DBI  핸들 대신 ORM으로 사용할 수 있는 DBIx::Class::Schema로 반환합니다.

=back
