package DeviewSched::Controller::UserAttendance;
use utf8;

use DeviewSched::FacebookAPI;

use Mojo::Base 'DeviewSched::Controller';

# FIXME: use base.. 로 상속받은 클래스에 Exporter를 사용할 수가 없었다.. ㅜㅜ 
sub FB_USER_REQUIRED_FIELDS () { DeviewSched::FacebookAPI->FB_USER_REQUIRED_FIELDS }

sub get_status {
    my $self = shift;

    my ($user, $fetch_all, $fetch_friend) = map { $self->stash($_) } qw/user fetch_all fetch_friend/;
    my ($year, $day) = map { $self->param($_) } qw/year day/;

    # FIXME: 멍청한 변수 선언
    my $facebook = $self->fb_graph($user->fb_token);
    my @friends_id;
    @friends_id = map { $_->{id}  } $facebook->friends if $fetch_friend;

    my $attendance_rs = $self->db_schema->resultset('UserAttendance');
    my @attendances   = $attendance_rs->search({
        session_year => $year,
        
        ( $fetch_friend ) ? 
        ( 
            ( !defined $fetch_all ) ? 
            ( session_day => $day ) : (),

            user_id => \@friends_id 
        ) : ( 
            user_id => $user->id 
        )
    }, {
        ( $fetch_friend ) ? 
        ( 
            join     => 'user',
            prefetch => 'user'
        ) : ()
    })->all;

    if ($fetch_friend) {
        return $self->render_wrap(200,
            ( $fetch_all ) ? 
            $self->_classify_by_days(\@attendances) :
            $self->_classify_by_user(\@attendances)
        );
    } else {
        return $self->render_wrap(200, 
            { days => $self->_classify_single(\@attendances) }
        );
    }

}

sub set_status {
    my $self = shift;
    
    my $user = $self->stash('user');
    my ($year, $day) = map { $self->param($_) } qw/year day/;
    my $attendance_rs = $self->db_schema->resultset('UserAttendance');

    if ($self->req->method eq $self->METHOD_PUT) {
        return $self->fail($self->FAIL_BAD_PARAMETERS) if $self->_get_last_day($year) < $day;

        $attendance_rs->update_or_create({
            user_id => $user->id,

            session_year => $year,
            session_day  => $day,
        });
    } else {
        $attendance_rs->search({
            user_id => $user->id,

            session_year => $year,
            session_day  => $day,
        })->delete;
    }

    return $self->render_wrap(200, {});
}

sub _get_last_day {
    my $self = shift;
    my $year = shift;
    
    my $session_rs = $self->db_schema->resultset('Session');
    my $last_day   = $session_rs->search({
        year => $year,
    })->get_column('day')->max;

    return $last_day;
}

sub _classify_single {
    my $self = shift; 
    my @attendances = @{ ( shift || []) };

    # must return {days: [1, 2, 3]}
    return [map {
        int $_->session_day
    } @attendances];
}

sub _classify_by_user {
    my $self = shift; 
    my @attendances = @{ ( shift || []) };

    # users: [1234, 1234, 1234]   
    my $result = { 
        users => [ map { 
            $_->user->serialize_columns([
                FB_USER_REQUIRED_FIELDS
            ]) 
        } @attendances ] 
    };
   
    return $result;
}

sub _classify_by_days {
    my $self = shift; 
    my @attendances = @{ ( shift || []) };

    # days: [{users: [1234, 1234, 1234]}, [1234, 1234, 1234], [1234, 1234, 1234]]
    my $result = [];
    map { 
        push @{ $result->[$_->session_day - 1]->{users} }, 
            $_->user->serialize_columns([
                FB_USER_REQUIRED_FIELDS
            ]);
    } @attendances;

    
    return {days => $result};
}

1;
