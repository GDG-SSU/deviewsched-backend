package DeviewSched::Controller::Users;
use utf8;

use Facebook::Graph;
use Mojo::Base 'DeviewSched::Controller';

sub FB_ME_REQUIRED_FIELDS () { ('id', 'name', 'picture') }

sub register {
    # FIXME: 토큰 갱신을 위해 (사용자가) 이미 있는지 확인 후 없을 경우에만 생성하도록 수정해야 함
    my $self = shift;
    my $auth_data = $self->stash('auth_data');

    my $token = $auth_data->{token}; 

    my $facebook = $self->fb_graph($token);
    my $response = $facebook->query
                            ->find('me')
                            ->select_fields(FB_ME_REQUIRED_FIELDS)
                            ->request
                            ->as_hashref;
    
    my $resultset = $self->db_schema->resultset('User');

    $resultset->create({
        fb_token => $token,

        id       => $response->{id},
        name     => $response->{name},
        picture  => $response->{picture},
    });

}

sub remove {
    my $self = shift;
}

sub get_info {
    my $self = shift;

    $self->render(text => 'OK!');
}

1;
