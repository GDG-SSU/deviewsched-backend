package DeviewSched::Controller::Sessions;
use utf8;

use Data::Dumper;

use Mojo::Base 'DeviewSched::Controller';


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

    # { 
    #   tracks => [ 
    #     { sessions => [{ session 1 }, { session 2 } ... ], }, # track #1
    #     { sessions => [{ session 5 }, { session 6 } ... ], }, # track #2
    #     { sessions => [{ session 7 }, { session 8 } ... ], }, # track #3
    #   ]
    # }
    #
    # 이런 느낌일려나! > <)

    my @tracks;

    my @sessions = $resultset->search({
        year => $self->stash('year'),   
    });

    for my $session (@sessions) {
        push @{($tracks[$session->track - 1]->{sessions})}, {
            %{ $session->serialize_columns([qw/id title/]) },
            speakers => [ map {
                $_->serialize_columns([qw/name picture/]);
            } $session->speakers ]
        };
    }
      
    $self->render(json => {
        tracks => \@tracks, 
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

=head2 METHODS


