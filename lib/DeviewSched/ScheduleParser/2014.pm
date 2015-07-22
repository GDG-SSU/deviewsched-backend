package DeviewSched::ScheduleParser::2014;
use 5.010;
use strict;
use warnings;

use Moose;
use Mojo::UserAgent;

with 'DeviewSched::Roles::ScheduleParser';

sub URL_SCHEDULE_LIST () { 'http://deview.kr/2014/schedule' }

sub schedule_list {
    my $self = shift;
    
}

1;
