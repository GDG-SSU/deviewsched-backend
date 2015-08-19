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

    # Routes
    my $router = $self->routes;


    $router->get('/years')->to('sessions#list_years');

    my $r_year = $router->under('/:year' => [RESTRICT_YEAR]);

    $r_year->get('/list' => [RESTRICT_ID])->to('sessions#list_sessions');
    $r_year->get('/:id'  => [RESTRICT_ID])->to('sessions#session_details');
    $r_year->get('/:id/speakers' => [RESTRICT_ID])->to('sessions#speakers');

    my $r_user = $router->under('/user')->to('authorization#validate');
    $r_user->post->to('users#register');
    $r_user->delete->to('users#remove');
    $r_user->get->to('users#get_info');

    $r_user->get('/friends')->to('users#friends_list');


}

1;
