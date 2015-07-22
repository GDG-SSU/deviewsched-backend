#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use lib 'lib';

use DeviewSched::ScheduleParser::2014;

my $parser = DeviewSched::ScheduleParser::2014->new; 
$parser->schedule_list;
say $parser->does('DeviewSched::Roles::ScheduleParser');