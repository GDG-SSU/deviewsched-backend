package DeviewSched;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    # Router
    my $router = $self->routes;

    # Normal route to controller
    $router->get('/')->to('example#welcome');
}

1;
