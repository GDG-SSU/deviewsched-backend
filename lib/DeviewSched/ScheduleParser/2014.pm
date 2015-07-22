package DeviewSched::ScheduleParser::2014;
use 5.010;
use utf8;
use strict;
use warnings;

use LWP::UserAgent;
use Mojo::DOM;

use Moose;

with 'DeviewSched::Roles::ScheduleParser';

sub URL_SCHEDULE_LIST   () { 'http://deview.kr/2014/schedule' }
sub URL_SESSION_DETAIL  () { 'http://deview.kr/2014/session?seq=%d' }

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
    
    
}


1;
