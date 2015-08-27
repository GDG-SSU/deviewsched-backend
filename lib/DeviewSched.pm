package DeviewSched;
use utf8;

use DeviewSched::ConfigHelper qw/load_config/;
use DeviewSched::Database qw/get_dbh/;

use Mojo::Base 'Mojolicious';

sub RESTRICT_YEAR () { (year => qr/\d{4}/) }
sub RESTRICT_ID   () { (id   => qr/\d+/) }

# This method will run once at server start
sub startup {
    my $self = shift;

    load_config($self);

    # Helper
    # TODO: Helper 기능을 다른 패키지로 나눠야 하는건 아닐까 싶은데 
    $self->helper('db_schema' => sub {
        my $self = shift;
        return get_dbh($self->config->{database}, 1);
    });

    $self->helper('fb_graph' => sub {
        my $self  = shift;
        my $token = shift;
        
        return Facebook::Graph->new(
            ($token) ? (access_token => $token) :
                       (app_id => $self->config->{facebook}->{appid},
                        secret => $self->config->{facebook}->{secret})
        );
    });

    # Routes
    my $router = $self->routes;


    $router->get('/years')->to('sessions#list_years');

    my $r_year = $router->under('/:year' => [RESTRICT_YEAR]);

    $r_year->get('/list' => [RESTRICT_ID])->to('sessions#list_sessions');
    $r_year->get('/:id'  => [RESTRICT_ID])->to('sessions#session_details');
    $r_year->get('/:id/speakers' => [RESTRICT_ID])->to('sessions#speakers');


    # 다른 라우트에도 이름을 붙여야 할 것인가.. 말아야 할 것인가..
    # (::Controller::Authorization::find_user에서 라우트 이름으로 사용자 등록인지 구분하고 있음) 
    my $r_user = $router->under('/user')->to('authorization#validate');
    $r_user->post->to('users#register')->name('register_user');
    $r_user->delete->to('users#delete');



    $r_user->get('/friends')->to('users#friends_list');


}

1;
