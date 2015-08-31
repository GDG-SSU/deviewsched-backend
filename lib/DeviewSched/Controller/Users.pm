package DeviewSched::Controller::Users;
use utf8;

use Data::Dumper;

use Facebook::Graph;
use Mojo::Base 'DeviewSched::Controller';

sub FB_ME_REQUIRED_FIELDS () { ('id', 'name', 'picture') }

sub register {
    my $self = shift;

    my $auth_data = $self->stash('auth_data');
    my $token     = $auth_data->{token}; 

    my $user = eval { $self->update_user($token) } 
        or return $self->fail($self->FAIL_INVALID_TOKEN, undef, $@);

    $self->stash(user => $user);

    my $user = $self->stash('user');

    return $self->render_wrap(200, {
        user => $user->serialize_columns([qw/id name picture/])
    });
}

sub update_user {
    my $self = shift;
    
    my $token = shift;
    my $facebook = $self->fb_graph($token);
    my $response = $facebook->query
             ->find('me')
             ->select_fields(FB_ME_REQUIRED_FIELDS)
             ->request
             ->as_hashref;

    my $resultset = $self->db_schema->resultset('User');
    my $user      = $resultset->update_or_create({
        fb_token => $token,

        id      => $response->{id},
        picture => $response->{picture}->{data}->{url},
        name    => $response->{name}
    }, {
        id => $response->{id}
    });

    return $user;
}

sub remove {
    my $self = shift;
}

1;
