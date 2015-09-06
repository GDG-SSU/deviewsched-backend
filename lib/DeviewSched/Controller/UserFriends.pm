package DeviewSched::Controller::UserFriends;
use utf8;

use DeviewSched::FacebookAPI;
use Mojo::Base qw/DeviewSched::Controller/;

sub FB_USER_REQUIRED_FIELDS () { DeviewSched::FacebookAPI->FB_USER_REQUIRED_FIELDS }

sub list {
    my $self = shift;

    my $user = $self->stash('user');

    my $facebook = $self->fb_graph($user->fb_token);
    my @friends  = eval { $facebook->friends }
        or return $self->fail($self->FAIL_UNKNOWN_ERROR, $@, $@);

    return $self->render_wrap(200, {
        friends => \@friends 
    });
}

sub session_list {
    my $self = shift;

    my $user        = $self->stash('user');
    my ($year, $id) = map { $self->param($_) } qw/year id/;

    my @friends;

    my $facebook    = $self->fb_graph($user->fb_token);
    my @all_friends = eval { $facebook->friends } 
        or return $self->fail($self->FAIL_UNKNOWN_ERROR, $@, $@);

    my @all_friends_id = map { $_->{id} } @friends;

    my $schedule_rs = $self->db_schema->resultset('UserSchedule');
    my @schedules   = $schedule_rs->search({
        'user_id'      => \@all_friends_id,

        'session_year' => $year,
        'session_id'   => $id
    }, {
        # FIXME : 살 려 주 세 요 ...
        #         조인만.. 하면.. 오류가.. 나는데..
        #         왜 이런 오류가 나는지 잘 모르겠어요..
        #         으악.. 암에.. 걸린다..
        #
        # select => [ ( map { 'user.'.$_ } FB_USER_REQUIRED_FIELDS ) ],
        # join   => 'user',
        # prefetch => 'user' 
    })->all; 
    
    

    for my $schedule (@schedules) {
        push @friends, $schedule->user->serialize_columns([FB_USER_REQUIRED_FIELDS]);
    }

    return $self->render_wrap(200, {friends => @friends});
}


1;
