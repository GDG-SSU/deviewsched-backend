package DeviewSched::Controller::Sessions;
use utf8;

use Mojo::Base 'DeviewSched::Controller';
use Time::HiRes qw/time/;

sub COLUMNS_LIST_SESSIONS_SESSION () { qw/id track day title starts_at ends_at/ }
sub COLUMNS_LIST_SESSIONS_SPEAKER () { qw/name picture/ }

sub list_years {
    my $self = shift;
    my $resultset = $self->db_schema->resultset('Session');

    my @result = map { $_->year } $resultset->search(undef, {
        columns => ['year'],
        distinct => 1,
    });
    
    $self->render(json => {
        years_available => \@result 
    });
}

sub list_sessions {
    my $self = shift;
    my $resultset = $self->db_schema->resultset('Session');

    my @data;

    my @sessions = $resultset->search({
        year => $self->stash('year'),   
    }, {

        select => [
            (map { "me.$_" } COLUMNS_LIST_SESSIONS_SESSION),
            (map { "speakers.$_" } COLUMNS_LIST_SESSIONS_SPEAKER),
        ],

        join     => 'speakers',
        prefetch => 'speakers',
        order_by => {
            -asc => 'starts_at'
        }
    });

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
     
    $self->render(json => {
        days => \@data, 
    });
}

sub session_details {
    my $self = shift;
    my $resultset = $self->db_schema->resultset('Session');
    
    my ($session) = $resultset->search({
        year => $self->stash('year'),
        id   => $self->stash('id'),
    });

    unless (defined $session) {
        return $self->fail($self->FAIL_RESOURCE_NOT_AVAILABLE);
    }

    $self->render(json => $session->serialize);
}

sub speakers {
    my $self = shift;
    my $resultset = $self->db_schema->resultset('Speaker');

    my @speakers = map { $_->serialize } $resultset->search({
        session_year => $self->stash('year'),
        session_id   => $self->stash('id'),    
    });

    $self->render(json => {
        year => $self->stash('year'),
        id   => $self->stash('id'),

        speakers => \@speakers
    });
} 

1;
__END__

=encoding utf-8

=head1 NAME

DeviewSched::Controller::Sessions - Deview 세션과 관련된 컨트롤러

=head2 ENDPOINTS


