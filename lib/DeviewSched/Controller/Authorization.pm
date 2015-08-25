package DeviewSched::Controller::Authorization;
use utf8;

use Digest::HMAC_SHA1 qw/hmac_sha1/;
use MIME::Base64 qw/encode_base64 decode_base64/;
use URL::Encode qw/url_encode_utf8/;

use Mojo::JSON qw/decode_json/;
use Mojo::Base 'DeviewSched::Controller';

sub validate {
    # ここはとにかく便乗して頑張るか！< そうだよ（便乗）
    
    my $self = shift;

    my $request = $self->req;
    my $auth_header = $request->headers->authorization;

    my $key = $self->config->{facebook}->{secret};
    
    if (defined $auth_header && $auth_header =~ m{^X-DeviewSchedAuth (?<AuthorizationData>[0-9a-zA-Z+/=]+)$}) {
        # last 문을 위한 코드 블럭
        VALIDATION: {
            my $auth_data;
            
            # 그냥 if문만 달랑 만들어놓고 last를 했더니 오류가 나더라.. ㅜㅜ 왜지?!?! 
            $auth_data = eval { decode_json(decode_base64($+{AuthorizationData})) };
            return $self->fail($self->FAIL_INVALID_AUTHORIZATION_HEADER, $@) if $@;

            $self->stash(auth_data => $auth_data);

            my $is_signature_valid = validate_signature($request, $auth_data, $key);
            my $is_user_found      = $self->find_user($auth_data->{token});

            # 확인 끝났으니 다음으로 넘어갑시다
            return 1 if $is_signature_valid && $is_user_found;

            # 아님 망고 
            return $self->fail($self->FAIL_AUTHORIZATION_FAILED);
        }
    }

    return $self->fail($self->FAIL_INVALID_AUTHORIZATION_HEADER);
}

sub validate_signature {
    my ($request, $auth_data, $key) = @_;

    my $signature = $auth_data->{signature};
    my $timestamp = $auth_data->{timestamp};    

    my $generated_signature = generate_signature($request, $auth_data, $key);

    return 1 if defined $signature                 &&
                defined $generated_signature       &&
                $signature eq $generated_signature &&
                is_timestamp_valid($timestamp);
}

sub is_timestamp_valid {
    my $timestamp = shift;
    
    return 1 if abs(time - $timestamp) <= 60 * 3;
}

sub generate_signature {
    my $request   = shift;
    my $auth_data = shift;
    my $key       = shift;

    my $token      = $auth_data->{token};
    my $timestamp  = $auth_data->{timestamp};
    my $nonce      = $auth_data->{nonce};

    my $serialized_parameters = serialize_parameters($request);

    return unless defined $key       &&
                  defined $token     && 
                  defined $timestamp && 
                  defined $nonce;

    my $raw_signature = join ":", ($timestamp, 
                                   $request->method, 
                                   $request->url->to_abs->path, 
                                   $token, 
                                   $serialized_parameters);

    my $signature = encode_base64(hmac_sha1($raw_signature, ($key . $nonce)));
    $signature =~ s/[\r\n]//g;
    return $signature;
}

sub serialize_parameters {
    my $request = shift;
    
    my %parameters = %{ $request->params->to_hash };

    my $serialized_parameters = "";
    my @keys = sort {$a cmp $b} keys %parameters;

    for my $key (@keys) {
        my $value = $parameters{$key};
        $serialized_parameters .= sprintf("%s=%s&", url_encode_utf8($key), url_encode_utf8($value)); 
    }

    # 마지막 &를 잘라내고 리턴
    return substr $serialized_parameters, 0, -1;
}

sub find_user {
    my $self  = shift;
    my $token = shift;

    return -1 if $self->current_route eq "register_user";

    my $resultset = $self->db_schema->resultset('User');
    my ($user) = $resultset->search({
        fb_token => $token, 
    });

    if (defined $user) {
        $self->stash(user => $user);
        return $user->id;
    }
}


1;
__END__

=encoding utf8

=head1 NAME

DeviewSched::Controller::Authorization - API 인증과 관련된 컨트롤러

