package DeviewSched::Controller::Users;
use utf8;

use Mojo::Base 'DeviewSched::Controller';

sub register {
    my $self = shift;
    
}

sub remove {
    my $self = shift;
}

sub get_info {
    my $self = shift;

    $self->render(text => 'OK!');
}

1;
