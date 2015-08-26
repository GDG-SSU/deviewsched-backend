package DeviewSched::Controller;

use Mojo::Base 'Mojolicious::Controller';

sub FAIL_RESOURCE_NOT_AVAILABLE       () { (404, "The request resource is not available") }
sub FAIL_INVALID_AUTHORIZATION_HEADER () { (401, "Invalid Authorization Header") }
sub FAIL_AUTHORIZATION_FAILED         () { (401, "Authorization Failed")  }

sub FAIL_INVALID_TOKEN                () { (401, "Invalid Token") }
sub FAIL_TOKEN_EXPIRED                () { (401, "Token Expired") }


sub FAIL_REASON_MALFORMED_JSON        () { "Malformed JSON" }
sub FAIL_REASON_AUTHORIZATION_HEADER  () { "Authorization header not defined" }

sub fail {
    my $self = shift;
    my ($code, $reason, $detail) = @_;

    $reason .= sprintf(" (%s)", $detail) if defined $detail;
    
    $self->render_wrap($code, { reason => $reason });
    return undef;
}

sub render_wrap {
    my $self = shift;
    my ($code, $content) = @_;

    # 좀 더 깔끔하게 못하나!
    $code = $self->stash('override_return_code') if $self->stash('override_return_code');

    my $is_success = ($code / 100 == 2) ? Mojo::JSON->true : Mojo::JSON->false;

    return $self->render(status => $code, json => { 
        is_success => $is_success, 
        (%{ $content }) 
    }); 
}

1;
