package DeviewSched::Controller::UserSchedule;
use utf8;

use Mojo::Base qw/DeviewSched::Controller/;

sub COLUMNS_LIST_SCHEDULES_SESSION () { qw/id track day title starts_at ends_at/ }

sub list {
    my $self = shift;

    my ($user, $fetch_all) = map { $self->stash($_) } qw/user fetch_all/;
    my ($year, $day)       = map { $self->param($_) } qw/year day/;
    
    return $self->fail($self->FAIL_BAD_PARAMETERS) 
        if (!(( defined $fetch_all && defined $year) ||
              ( defined $year && defined $day)));


    my $search_conditions = {
        ( !defined $fetch_all ) ? 

        (
            'session.year' => $year,
            'session.day'  => $day,
        ) : (
            'session.year' => $year
        )
    };

    my $schedule_rs = $user->schedules->search_rs($search_conditions, {
        select => [
            (map { "session.$_" } COLUMNS_LIST_SCHEDULES_SESSION) 
        ],

        join     => 'session',
        prefetch => 'session'
    });

    my @sessions;

    map { 
        push @sessions, $_->session->serialize_columns(
            COLUMNS_LIST_SCHEDULES_SESSION
        ); 
    } $schedule_rs->all; 
    
    return $self->render_wrap(200, {
        sessions => \@sessions    
    });
}

sub register {
    my $self = shift;

    my $user = $self->stash('user');
    my ($session_year, $session_id) = map { $self->param } qw/year id/;


}

sub unregister {
    my $self = shift;

}

sub unregister_all {
    my $self = shift;

}

sub _find_collisions {
    my $self    = shift;

    my $session   = shift;
    
    my $resultset = $self->db_schema->resultset('Session');
    my (@result) = $resultset->search({
        year => $session->year,
        day  => $session->day,

    });

}


1;
