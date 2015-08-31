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

        # 한 리퀘스트 내에서는 같은 스키마를 재사용 하도록 합니다.
        unless (defined $self->stash('_db_schema')) {
            $self->stash('_db_schema' => get_dbh($self->config->{database}, 1));
        }

        return $self->stash('_db_schema');
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

    $self->plugin('PODRenderer');

    # Routes
    my $router = $self->routes;


    $router->get('/years')->to('sessions#list_years');

    my $r_year = $router->under('/:year' => [RESTRICT_YEAR]);

    $r_year->get('/list'         => [RESTRICT_ID])->to('sessions#list_sessions');
    $r_year->get('/:id'          => [RESTRICT_ID])->to('sessions#session_details');
    $r_year->get('/:id/speakers' => [RESTRICT_ID])->to('sessions#speakers');


    # 다른 라우트에도 이름을 붙여야 할 것인가.. 말아야 할 것인가..
    # (::Controller::Authorization::find_user에서 라우트 이름으로 사용자 등록인지 구분하고 있음) 
    my $r_user = $router->under('/user')->to('authorization#validate');

    $r_user->post  ->to('users#register')->name('register_user');
    $r_user->delete->to('users#delete');
    
    # user schedule
    $r_user->get('/schedule')    ->to('user_schedule#list');
    $r_user->get('/schedule/all')->to('user_schedule#list', fetch_all => 1);

    $r_user->any([qw/PUT DELETE/] => '/schedule')    ->to('user_schedule#process');
    $r_user->any([qw/PUT DELETE/] => '/schedule/all')->to('user_schedule#process_all');

    # friends
    $r_user->get('/friends')->to('users#friends_list');


    $router->any([qw/SORRY/] => '/im_late')->to(cb => sub {
        shift->render(text => "계속 늦어져서 미안해요 > <);");
    });
}

1;
