package DeviewSched::SessionListUtils;
use 5.010;
use strict;
use warnings;

use Exporter;

our @ISA       = qw/Exporter/;
our @EXPORT_OK = qw/COLUMNS_LIST_SESSIONS_SESSION COLUMNS_LIST_SESSIONS_SPEAKER/;

sub COLUMNS_LIST_SESSIONS_SESSION () { qw/id track day title starts_at ends_at/ }
sub COLUMNS_LIST_SESSIONS_SPEAKER () { qw/name picture/ }

sub classify_by_days {
    my @sessions = @{ ((shift) || []) };
    my @data;

    for my $session (@sessions) {

        my $day   = $session->day;
        my $track = $session->track;

        push @{($data[$day - 1]->{tracks}[$track - 1]->{sessions})}, {
            %{ $session->serialize_columns([COLUMNS_LIST_SESSIONS_SESSION]) },
            speakers => [ map {
                $_->serialize_columns([COLUMNS_LIST_SESSIONS_SPEAKER]);
            } $session->speakers ]
        };
    }

   return \@data; 
}



1;
