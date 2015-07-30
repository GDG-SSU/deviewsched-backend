package DeviewSched::Controller::Sessions;
use utf8;

use Data::Dumper;

use Mojo::Base 'Mojolicious::Controller';

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

    my @sessions = map { $_->serialize_columns([qw/year id title/]) } $resultset->search({
        year => $self->stash('year'),   
    });
    
    $self->render(json => {
        sessions_available => \@sessions,
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
        return $self->render(json => {
            reason => 'the requested resource is not available'
        }, status => 404);
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
