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

    my $facebook = $self->fb_graph($token);
    my $response = eval { 
        $facebook->query
                 ->find('me')
                 ->select_fields(FB_ME_REQUIRED_FIELDS)
                 ->request
                 ->as_hashref;
    } or return $self->fail($self->FAIL_INVALID_TOKEN);
    
    my $resultset = $self->db_schema->resultset('User');
    my ($user)    = $resultset->search({
        id => $response->{id}
    });

    unless (defined $user) {
        # 사용자가 없을 경우 새로 생성합니다
        
        # 리턴 코드를 201로 따로 설정함
        $self->stash(override_return_code => 201);

        $user = $resultset->create({
            fb_token => $token,

            id       => $response->{id},
            name     => $response->{name},
            picture  => $response->{picture}->{data}->{url},
        });
    } else {
        # 적당히 토큰만 갱신합니다 
        $user->fb_token($token);
        $user->update;
    }

    $self->stash(user => $user);

    return $self->get_info;
}

sub remove {
    my $self = shift;
}

sub get_info {
    my $self = shift;

    my $user = $self->stash('user');
    return $self->render_wrap(200, $user->serialize_columns(
        [qw/id name picture/]
    ));
}

1;
