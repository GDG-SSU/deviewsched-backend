package DeviewSched::ScheduleParser::2014;
use 5.010;
use utf8;
use strict;
use warnings;

use DateTime;
use LWP::UserAgent;
use Mojo::DOM;

use Moose;

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
    return $self->_parse_session_detail($res->decoded_content); 
}

sub _parse_session_detail {
    my $self     = shift;
    my $raw_html = shift;
    
    my $dom = Mojo::DOM->new($raw_html);
 
    my %info  = $self->_parse_session_info($dom);
    my %speaker_info = $self->_parse_session_speakers($dom);

    my %session = (
        %info,
        %speaker_info,

        title       => $dom->at('')->text,
        description => $dom->at('div.speaker_txt > p.txt')->content,

    );
}

sub _parse_session_info {
    my ($self, $dom) = @_;
    my $info = $dom->at('div.pos_r p.view_info')->find('.av55');
    
    my $i = 0;
    my $info_arrayref = $info->map(sub {
        my $text = $_->text;
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

    return (
        day         => $day,
        track       => $track,
        session_num => $session_num,
        starts_at   => $starts_at,
        ends_at     => $ends_at,
    );
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
    my ($self, $dom) = @_;

    my $speakers      = $dom->at('div.speaker_info')->children('div.speaker_box');
    my $introductions = $dom->at('div.speaker_intro');

    for (1..$speakers->size) {
        my (undef, $introduce) = splice @$introductions, 0, 2;
    }
}

1;
