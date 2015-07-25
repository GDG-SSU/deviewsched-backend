package DeviewSched::Roles::ScheduleCrawler;
use 5.010;
use strict;
use warnings;
use utf8;

use LWP::UserAgent;

use Moose::Role;

sub _UA_DEFAULT_USERAGENT () { sprintf 'Mozilla/5.0 (%s) Perl/%s github:GDG-SSU/deviewsched-backend', $^O, $^V }

has '_ua' => (
    is      => 'ro',
    isa     => 'LWP::UserAgent',
    default =>  sub { LWP::UserAgent->new( agent => _UA_DEFAULT_USERAGENT ) },
);

has 'db_schema' => (
    is  => 'ro',
    isa => 'DeviewSched::Schema',
    required => 1
);

requires 'schedule_list';
requires 'session_detail';

sub _request {
    my $self   = shift;
    my $method = shift;
    my ($url)  = @_;

    my $res = $self->_ua->$method(@_);
    unless ($res->is_success) {
        warn sprintf "[WARN] HTTP Request failed: [%s] %s => %s", 
            $res->status_line, $method, $url;
    }

    return $res;
}

1;
__END__

=encoding utf-8

=head1 NAME

DeviewSched::Roles::ScheduleCrawler - ScheduleCrawler Moose Role

=head1 SYNOPSIS

    # writing parser
    package DeviewSched::ScheduleCrawler::YYYY;
    use Moose;
    
    # implements DeviewSched::Roles::ScheduleCrawler
    with 'DeviewSched::Roles::ScheduleCrawler';
    
    sub schedule_list {
        my $self = shift;
        my @schedule_list;
    
        # blah blah ...
    
        return @schedule_list;
    } 
    
    sub session_detail {
        my $self = shift;
        my $session_id = shift;
        my $session    = DeviewSched::Session->new;

        # ...
        
        return $session;
    }
    
    # using existing parser
    package Main;
    use DeviewSched::ScheduleCrawler::YYYY;
    my $parser = DeviewSched::ScheduleCrawler::YYYY->new;
    
    my @schedule_list = $parser->schedule_list;
    for my $session_id (@schedule_list) {
        my $session = $parser->session_detail($session_id);
        printf "[Day %d Track %d] %s\n", $session->day, $session->track, $session->title;
    }

=head1 DESCRIPTION

DeviewSched::Roles::ScheduleCrawler는ScheduleCrawler의 Moose Role입니다.

=head2 ATTRIBUTES

=over 4

=item C<_ua>

LWP::UserAgent 인스턴스입니다.

=back

=head2 METHODS

이 Role을 상속하는 ScheduleCrawler 클래스는 아래 메소드가 반드시 구현되어 있어야 합니다.

=over 4

=item C<schedule_list>

스케쥴 목록을 가져옵니다. 
각 세션에 대한 id가 담긴 리스트를 반환해야 합니다.

=item C<session_detail>

세션의 상세 정보를 가져옵니다. 
DeviewSched::Session 인스턴스를 반환해야 합니다.

=back

=head1 AUTHOR

Gyuhwan Park (unstabler) E<lt>doping.cheese@gmail.comE<gt>

=cut
