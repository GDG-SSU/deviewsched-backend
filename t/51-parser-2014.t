use Test::More tests => 1;
use DeviewSched::ScheduleParser::2014;

my $instance = DeviewSched::ScheduleParser::2014->new;
ok(ref $instance eq "DeviewSched::ScheduleParser::2014", 
   "Creating Instance");

