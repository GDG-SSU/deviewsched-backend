package DeviewSched::Roles::ScheduleParser;
use 5.010;
use strict;
use warnings;
use utf8;

use LWP::UserAgent;
use Moose::Role;

requires 'schedule_list';
requires 'schedule_detail';

sub BUILD {
    my $self = shift;
}

__END__

=encoding utf-8

=head1 NAME

DeviewSched::Roles::ScheduleParser - ScheduleParser Moose Role

=head1 SYNOPSIS

    # writing parser
    package DeviewSched::ScheduleParser::YYYY;
    use Moose;
    
    # implements DeviewSched::Roles::ScheduleParser
    with 'DeviewSched::Roles::ScheduleParser';
    
    sub schedule_list {
        my $self = shift;
        my @schedule_list;
    
        # blah blah ...
    
        return @schedule_list;
    } 
    
    sub schedule_detail {
        my $self = shift;
        my $schedule = DeviewSched::Schedule->new;

        # ...
        
        return $schedule;
    }
    
    # using existing parser
    package Main;
    use DeviewSched::ScheduleParser::YYYY;
    my $parser = DeviewSched::ScheduleParser::YYYY->new;
    
    my @schedule_list = $parser->schedule_list;
    for my $schedule_id (@schedule_list) {
        my $schedule = $parser->schedule_detail($schedule_id);
        printf "[Day %d] %s\n", $schedule->day, $schedule->title;
    }

=head1 DESCRIPTION

DeviewSched::Roles::ScheduleParser는ScheduleParser의 Moose Role입니다.

=head2 METHODS

이 Role을 상속하는 ScheduleParser 클래스는 아래 메소드가 반드시 구현되어 있어야 합니다.

=over 4

=item C<schedule_list>

스케쥴 목록을 가져옵니다. 
각 스케쥴에 대한 id가 담긴 리스트를 반환해야 합니다.

=item C<schedule_detail>

스케쥴의 상세 정보를 가져옵니다. 
DeviewSched::Schedule 를 반환해야 합니다.

=back

=head1 AUTHOR

Gyuhwan Park (unstabler) E<lt>doping.cheese@gmail.comE<gt>

=cut
