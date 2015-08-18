package DeviewSched::Controller;

use Mojo::Base 'Mojolicious::Controller';

sub FAIL_RESOURCE_NOT_AVAILABLE       () { (404, "The request resource is not available") }
sub FAIL_INVALID_AUTHORIZATION_HEADER () { (401, "Invalid Authorization Header") }

sub fail {
    my $self = shift;
    my ($code, $message) = @_;

    $self->render_wrap($code, { reason => $message });
    return undef;
}

sub render_wrap {
    my $self = shift;
    my ($code, $content) = @_;

    my $is_success = ($code % 100 == 2) ? Mojo::JSON->true : Mojo::JSON->false;

    return $self->render(status => $code, json => { 
        is_success => $is_success, 
        (%{ $content }) 
    }); 
}

1;
