package DeviewSched::Controller::UserSchedule;
use utf8;

use Mojo::Base qw/DeviewSched::Controller/;

use DeviewSched::SessionListUtils
    qw/COLUMNS_LIST_SESSIONS_SESSION COLUMNS_LIST_SESSIONS_SPEAKER/;

sub COLUMNS_LIST_SCHEDULES_SESSION () { COLUMNS_LIST_SESSIONS_SESSION }
    
sub METHOD_PUT    () { 'PUT' }
sub METHOD_DELETE () { 'DELETE' }

sub list {
    my $self = shift;

    # $fetch_all으로 /user/schedules/all이 호출되었는지 여부를 확인합니다.
    my ($user, $fetch_all) = map { $self->stash($_) } qw/user fetch_all/;
    my ($year, $day)       = map { $self->param($_) } qw/year day/;
    
    return $self->fail($self->FAIL_BAD_PARAMETERS) 
        if (!(( defined $fetch_all && defined $year ) ||
              ( defined $year && defined $day )));


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
            ( map { "session.$_" } COLUMNS_LIST_SCHEDULES_SESSION ) 
        ],

        join     => 'session',
        prefetch => 'session',
        order_by => {
            -asc => 'session.starts_at'
        }
    });

    my $days = DeviewSched::SessionListUtils::classify_by_days([
        map {
            $_->session
        } $schedule_rs->all
    ]);

    return $self->render_wrap(200, {
        (defined $fetch_all) ? (
            days   => $days
        ) : (
            tracks => $days->[$day - 1]
        )
    });
}

sub process {
    my $self = shift;

    my $user   = $self->stash('user');
    my $method = $self->req->method;
    my ($session_year, $session_id) = map { $self->param($_) } qw/year id/;
    
    if ($method eq METHOD_PUT) { 
        my $schedule     = eval { $self->_register_schedule($user, $session_year, $session_id) } 
                           or return $self->fail($self->FAIL_SCHEDULE_INSERTION, $@, $@);

        my $collision_id = $self->stash('collision_id');
        
        if (defined $collision_id) {
            return $self->render_wrap(200, { collision_id => $collision_id });
        } else {
            return $self->render_wrap(201);
        }
    } elsif ($method eq METHOD_DELETE) {
        my $schedule = $self->_find_schedule($user, $session_year, $session_id);

        if (defined $schedule) {
            $schedule->delete;
            return $self->render_wrap(200);
        } else {
            return $self->fail($self->FAIL_SCHEDULE_NOT_FOUND);
        }
    }

    return $self->fail($self->FAIL_UNKNOWN_ERROR);
}

sub process_all {
    my $self = shift;

    my $user   = $self->stash('user');
    my $method = $self->req->method;
    my ($session_year, $data) = map { $self->param($_) } qw/year data/;

    # 트랜잭션 개시
    my $tx_guard = $self->db_schema->txn_scope_guard;

    # remove all schedules
    my $resultset = $self->db_schema->resultset('UserSchedule')
                         ->search_rs({
        user_id      => $user->id,
        session_year => $session_year
    });

    $resultset->delete_all();


    if ($method eq METHOD_PUT) { 
        my @sessions = split ",", $data;
        
        for my $session_id (@sessions) {
            eval {
                $self->_register_schedule($user, $session_year, $session_id);
            } or return $self->fail($self->FAIL_SCHEDULE_INSERTION, $@, $@); 
        }
    }

    # 트랜잭션 커밋
    $tx_guard->commit;

    return $self->render_wrap(200);
}

sub _register_schedule {
    my $self = shift;
    my ($user, $session_year, $session_id, $db_schema) = @_;

    my $session = $self->_find_session($session_year, $session_id);
    die "Session not found" unless defined $session;   
    
    my $old_schedule = $self->_find_collision($user, $session);
    if (defined $old_schedule) {
        $self->stash('collision_id' => $old_schedule->session_id);
        $old_schedule->delete;
    }

    my $resultset = $self->db_schema->resultset('UserSchedule');
    my $schedule  = $resultset->create({
        user_id      => $user->id,

        session_year => $session->year,
        session_id   => $session->id,
    }); 
    
    return $schedule;
}

sub _find_schedule {
    my $self = shift;
    my ($user, $session_year, $session_id) = @_;

    my ($schedule) = $user->schedules->search({
        session_year => $session_year,
        session_id   => $session_id
    });

    return $schedule;
}

sub _find_session {
    my $self = shift;
    my ($session_year, $session_id) = @_;

    my ($session) = $self->db_schema->resultset('Session')->search({
        year => $session_year,
        id   => $session_id
    });

    return $session;
}

sub _find_collision {
    my $self = shift;
    my ($user, $session) = @_;
    
    my $schedule_rs = $user->schedules->search_rs({
        # TODO : 충돌 찾기
        'me.user_id' => $user->id,

        'cast(extract(epoch from session.starts_at) as integer)' => $session->starts_at->epoch,
        'cast(extract(epoch from session.ends_at) as integer)'   => $session->ends_at->epoch
    }, {
        join     => 'session',
        prefetch => 'session'
    });
   
    return $schedule_rs->first;
}


1;
__END__

=encoding utf-8

=head1 NAME

DeviewSched::Controller::UserSchedule - 사용자 스케줄 API 컨트롤러

=head1 ENDPOINTS

=over 4



=back

=head1 METHODS

=over 4

=item C<_register_schedule($user, $session)>

C<$user>의 스케줄 목록에 C<$session>을 등록합니다.

=item C<_unregister_schedule($user, $schedule)>

C<$user>의 스케줄 목록으로부터 C<$schedule>를 제거합니다.

=item C<_find_collision($user, $session)>

C<$user>가 등록한 스케줄 목록에서 C<$session>과 시간이 겹치는 스케줄을 찾습니다.

=back

