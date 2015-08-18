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
    $self->helper('db_schema' => sub {
        my $self = shift;
        return get_dbh($self->config->{database}, 1);
    });

    # Router
    my $router = $self->routes;

    $router->get('/years')->to('sessions#list_years');

    $router->get('/:year/list' => [RESTRICT_YEAR, RESTRICT_ID])->to('sessions#list_sessions');
    $router->get('/:year/:id'  => [RESTRICT_YEAR, RESTRICT_ID])->to('sessions#session_details');
    $router->get('/:year/:id/speakers' => [RESTRICT_YEAR, RESTRICT_ID])->to('sessions#speakers');

    my $user = $router->under('/user')->to('authorization#validate');
    $user->post->to('users#register');
    $user->delete->to('users#remove');
    $user->get->to('users#get_info');

    $user->get('/friends')->to('users#friends_list');


}

1;
