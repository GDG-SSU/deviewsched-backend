package DeviewSched::Controller::Authorization;

use Digest::HMAC_SHA1 qw/hmac_sha1/;
use MIME::Base64 qw/encode_base64 decode_base64/;
use URL::Encode qw/url_encode_utf8/;

use Mojo::JSON;
use Mojo::Base 'DeviewSched::Controller';

sub validate {
    # ここはとにかく便乗して頑張るか！< そうだよ（便乗）
    
    my $self = shift;
    my $request = $self->req;
    my $auth_header = $request->headers->authorization;
    
    if (defined $auth_header && $auth_header =~ m{^X-DeviewSchedAuth (?<AuthorizationData>[a-zA-Z+/=]+)$}) {
        my $auth_data = decode_json(decode_base64($+{AuthorizationData}));
        $self->stash(auth_data => $auth_data);

        # 확인 끝났으니 다음으로 넘어갑시다
        return 1 if $self->validate_signature($auth_data, $request);
    }

    # 아님 망고 
    return $self->fail($self->FAIL_INVALID_AUTHORIZATION_HEADER);
}

sub validate_signature {
    my $self = shift;

    my ($auth_data, $request) = @_;

    my $signature           = $auth_data->{signature};
    my $generated_signature = $self->generate_signature($auth_data, $request);

    if (defined $signature           &&
        defined $generated_signature && 
        $signature eq $generated_signature) {
        return 1;
    }

    return;
}

sub generate_signature {
    my $self = shift;
    my $auth_data = shift;
    my $request   = shift;
    my $key       = shift || $self->config->{facebook}->{secret};

    my $token      = $auth_data->{token};
    my $timestamp  = $auth_data->{timestamp};
    my $nonce      = $auth_data->{nonce};

    my $serialized_parameters = $self->serialize_parameters($request);

    return unless defined $token     && 
                  defined $timestamp && 
                  defined $nonce;

    my $raw_signature = join ":", ($timestamp, $request->method, $request->url->to_abs->path, $token, $serialized_parameters);

    return hmac_sha1($raw_signature, ($key . $nonce));
}

sub serialize_parameters {
    my $self    = shift;
    my $request = shift;
    
    my %parameters = $request->params->to_hash;

    my $serialized_parameters = "";
    my @keys = sort {$a cmp $b} keys %parameters;

    for my $key (@keys) {
        my $value = $parameters{$key};
        $serialized_parameters .= sprintf("%s=%s&", url_encode_utf8($key), url_encode_utf8($value)); 
    }

    # 마지막 &를 잘라내고 리턴
    return substr $serialized_parameters, 0, -1;
}

1;
__END__

=encoding utf8

=head1 NAME

DeviewSched::Controller::Authorization - API 인증과 관련된 컨트롤러

=head1 WARNING

아직 작동 확인 하지 않았습니다 
