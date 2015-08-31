use utf8;

use Test::More tests => 3;
use Test::Mojo;

sub DEFAULT_LOCALE () { 'ko_KR' }
sub STRING_SORRY   () { {ko_KR => '미안해요'} }

my $string_sorry = STRING_SORRY()->{ DEFAULT_LOCALE() };

my $test = Test::Mojo->new('DeviewSched');


# 정말 진심을 담아서 사과하고 있는지 확인

my $tx = $test->ua->build_tx(SORRY => '/im_late');
$test->request_ok($tx)
     ->status_is(200)
     ->content_like(qr/$string_sorry/);
