package DeviewSched::ScheduleParser::2014;
use 5.010;
use utf8;
use strict;
use warnings;

use DateTime;
use LWP::UserAgent;
use Mojo::DOM;

use Moose;

use Data::Dumper;

with 'DeviewSched::Roles::ScheduleParser';

sub URL_SCHEDULE_LIST         () { 'http://deview.kr/2014/schedule' }
sub URL_FORMAT_SESSION_DETAIL () { 'http://deview.kr/2014/session?seq=%d' }

sub YEAR       () { 2014 }
sub DEFAULT_TZ () { 'Asia/Seoul' }

sub REGEX_SESSION_INFO () {[
    qr{^DAY (\d)$},              # DAY 1
    qr{^(\d+)\.(\d+)},           # 09.29 (월)
    qr{^TRACK (\d)},             # TRACK 1
    qr{^세션 (\d)},              # 세션 1
    qr{^(\d+:\d+) ~ (\d+:\d+)$}  # 10:00 ~ 10:45
]}

sub schedule_list {
    my $self = shift;
    my $res  = $self->_request('get', URL_SCHEDULE_LIST);
    
    return unless $res->is_success;
    return $self->_parse_schedule_list($res->decoded_content);
}

sub _parse_schedule_list {
    my $self     = shift;
    my $raw_html = shift;

    my $dom = Mojo::DOM->new($raw_html);
    my @schedule_list = $dom->find('div.lst_track dl')->map(sub {
            $_->attr('data-sessionseq')
    })->each;

    return @schedule_list;
}

sub session_detail {
    my $self        = shift;
    my $session_id  = shift;
    
    my $url = sprintf URL_FORMAT_SESSION_DETAIL, $session_id; 
    my $res = $self->_request('get', $url);

    return unless $res->is_success;
    return $self->_parse_session_detail($session_id, $res->decoded_content); 
}

sub _parse_session_detail {
    my $self     = shift;

    my $session_id = shift;
    my $raw_html   = shift;
    
    my $dom = Mojo::DOM->new($raw_html);
 
    $self->_parse_session_info($session_id, $dom);
    $self->_parse_session_speakers($session_id, $dom);
}

sub _parse_session_info {

    # TODO: 강의 대상 / 발표 자료 / 동영상 저장

    my ($self, $session_id, $dom) = @_;

    my $info = $dom->at('div.pos_r p.view_info')->find('.av55');
    
    my $i = 0;

    my $info_arrayref = $info->map(sub {
        my $text  = $_->text;
        my $regex = REGEX_SESSION_INFO()->[$i++];
        my @match = $text =~ $regex;
        return ($#match == 1) ? \@match : shift @match;
    })->to_array;


    # DAY 1 09.29(월) / TRACK 1 / 세션 1 10:00 ~ 10:45
    my ($day,          # DAY 1
        $date,         # 09.29 (월)
        $track,        # TRACK 1
        $session_num,  # 세션 1
        $time          # 10:00 ~ 10:45
    ) = @$info_arrayref; 
    
    my $date_dt = DateTime->new(
        year  => YEAR,
        month => $date->[0],
        day   => $date->[1],
        time_zone => DEFAULT_TZ,
    );

    my ($starts_at, $ends_at) = map { 
        $self->_session_time_to_datetime($date_dt, $_) 
    } @$time;


    my %session_info = (
        # OMG, TIT!?!?
        title       => $dom->at('h3.tit_txt')->text,
        description => $dom->at('div.speaker_txt > p.txt')->content,

        day         => $day,
        track       => $track,
        session_num => $session_num,
        starts_at   => $starts_at,
        ends_at     => $ends_at,
    );

    $self->_insert_session_info($session_id, \%session_info);
}

sub _session_time_to_datetime {
    my ($self, $date, $time) = @_;

    my ($hour, $minute) = split ":", $time;
    my $new_date = $date->clone;

    $new_date->set(
        hour   => $hour,
        minute => $minute,
    );

    return $new_date;
}



sub _parse_session_speakers {

    # TODO: 홈 페이지 주소 / email 주소 / github, facebook, twt ... 저장

    my ($self, $session_id, $dom) = @_;

    my $speakers_info = $dom->at('div.speaker_info')->children('div.speaker_box');
    my $introductions = $dom->at('dl.speaker_intro')->children('dt, dd');

    for my $i (0..$speakers_info->size - 1) {
        # <dt></dt>, <dd></dd>
        # <dt></dt>는 사용하지 않음
        my $dom_speaker_info = $speakers_info->[$i];
        my (undef, $dom_speaker_introduce) = splice @$introductions, 0, 2;

        my %speaker = $self->_parse_session_speaker_info($dom_speaker_info, $dom_speaker_introduce); 
        $self->_insert_speaker_info($session_id, \%speaker);
    }


}

sub _parse_session_speaker_info {
    my ($self, $dom_speaker_info, $dom_speaker_introduce) = @_;

    my $strong           = $dom_speaker_info->at('strong');
    my $dom_organization = pop @$strong;

    my %speaker  = (
        name            => $strong->text,
        organization    => $dom_organization->text,
        # <dd></dd> 태그에 자식 노드가 있는 경우도 있어서 text 대신 all_text를 사용 
        introduction   => $dom_speaker_introduce->all_text,

        picture => ($dom_speaker_info->at('span.speaker_p > img')->attr('src') || ''),
    );

    return %speaker;
}

sub _insert_speaker_info {
    my ($self, $session_id, $speaker_info) = @_;

    my $resultset = $self->db_schema->resultset('Speaker');
    my $count = $resultset->search({
        session_year => YEAR,
        session_id   => $session_id,
        name         => $speaker_info->{name},
    }, { select => 'count' })->count;

    if ($count) {
        warn sprintf "[SKIP] Already Exists: %d/%d %s\n", YEAR, $session_id, $speaker_info->{name}; 
        return;
    }
 

    $resultset->create({
        session_year => YEAR,
        session_id   => $session_id,

        %$speaker_info,
    });
    
}

sub _insert_session_info {

    # TODO: 정보 갱신시 DB 내의 정보 역시 업데이트 되어야 함
    #       이미 끝난 행사라 그럴 일 없겠지만.. (´・ω・｀)

    my ($self, $session_id, $session_info) = @_;

    my $resultset = $self->db_schema->resultset('Session');
    my $count = $resultset->search({
        year => YEAR,
        id   => $session_id,
    }, { select => 'count' })->count;

    if ($count) {
        warn sprintf "[SKIP] Already Exists: %d/%d %s\n", YEAR, $session_id, $session_info->{title}; 
        return;
    }
    
    $resultset->create({
        year => YEAR,
        id   => $session_id,

        %$session_info
    });
}

1;

__END__

=encoding utf-8

=head1 NAME

DeviewSched::ScheduleParser::2014 - Deview 2014의 프로그램 목록을 크롤링 합니다

