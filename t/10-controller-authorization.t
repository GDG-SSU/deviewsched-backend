use Test::More tests => 2;
use Test::Mojo;

use MIME::Base64 qw/encode_base64/;

use DeviewSched::Controller::Authorization;

# do test with static data

my $expected_parameters = 'comment=Perl+wa+Nandemo+Dekichau+Kyuukyoku+no+Gengo%2C+Hakkiri+Wakandane%21&favorite_drink=%C3%A3%C2%82%C2%A2%C3%A3%C2%82%C2%A4%C3%A3%C2%82%C2%B9%C3%A3%C2%83%C2%86%C3%A3%C2%82%C2%A3%C3%A3%C2%83%C2%BC&name=%C3%A7%C2%94%C2%B0%C3%A6%C2%89%C2%80';
my $expected_signature  = 'KlO2YG/i7sidLZVFEH7eaZcYsdo=';

my $key = 'GVqymWaC532y895uP0sMKSbLmwNK+SKMMriYC958t4i+skQkNGbHqG+V8waFWsEad8E5RhlVRpbfW5vxeudoWI4B/vs0N/ewVvnG4wA+x0PVe9Dl0nzynS2J4tpK/vwG6OfGZcRx/De71B68CNi2O0SQrJB3oqXYkkuzuycRPi8=';

my $auth_data = {
    token => '11451481019198894504482048101000811919',
    timestamp => 1439977267,
    nonce => 'fvfLqqpSeg1tLAXG7X8jgNlgdGkiLnDpq5WM9z6cCQA=',
};

my $params = Mojo::Parameters->new(
    name    => '田所',
    comment => 'Perl wa Nandemo Dekichau Kyuukyoku no Gengo, Hakkiri Wakandane!',
    favorite_drink => 'アイスティー'
);

my $request = Mojo::Message::Request->new;

$request->url(Mojo::URL->new('http://localhost:3000/test'));
$request->method('POST');
$request->params->merge($params);

is(DeviewSched::Controller::Authorization::serialize_parameters($request), $expected_parameters, 'serialize parameters');

is(DeviewSched::Controller::Authorization::generate_signature($request, $auth_data, $key), $expected_signature, 'generate signature');

sub generate_random {
    my $length = shift || 32;
    my $buffer;

    open my $devrandom, '<', '/dev/urandom' or fail("cannot open /dev/urandom");
    binmode $devrandom;
    
    read $devrandom, $buffer, $length;
    
    close $devrandom;
    
    my $random_data = encode_base64($buffer);
    chomp $random_data;

    return $random_data;
}
