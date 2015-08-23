package DeviewSched::ScheduleCrawler;
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
requires 'YEAR';

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


sub _build_session_info {
    my ($self, $session_id, $session_info) = @_;

    my $resultset = $self->db_schema->resultset('Session');
    my $session   = $resultset->find_or_new({
        year => $self->YEAR,
        id   => $session_id,
    });

    while (my ($key, $value) = each %$session_info) {
        $session->$key($value);
    }

    return $session;
}

sub _build_speaker_info {
    my ($self, $session_id, $speaker_info) = @_;

    my $resultset = $self->db_schema->resultset('Speaker');
    my $speaker   = $resultset->find_or_new({
        session_year => $self->YEAR,
        session_id   => $session_id,
        name         => $speaker_info->{name},
    });
    
    while (my ($key, $value) = each %$speaker_info) {
        $speaker->$key($value);
    }

    return $speaker;
}


1;
__END__

=encoding utf-8

=head1 NAME

DeviewSched::ScheduleCrawler - ScheduleCrawler Moose Role (base class)

=head1 SYNOPSIS

    # 크롤러 작성 
    package DeviewSched::ScheduleCrawler::2048;
    use Moose;
    
    # implements DeviewSched::ScheduleCrawler
    with 'DeviewSched::ScheduleCrawler';
    
    sub YEAR () { 2048 }
    
    sub schedule_list {
        my $self = shift;
        my @schedule_list;
        
        my $response = $self->_request('get', URL_SCHEDULE_LIST);
        
        # TODO: parse schedule list
        warn "체험판에서는 보여드릴 수 없습니다.";
        # ...
        
        return @schedule_list;
    } 
    
    sub session_detail {
        my $self = shift;
        my $session_id = shift;
        
        my $session_detail_url = sprintf URL_SESSION_DETAIL, $session_id;
        
        # 우리 요청은 서버에 가 있어! 곧 응답을 들고 돌아올 거라고!!
        my $response = $self->_request('get', $session_detail_url);
        
        unless ($response->is_success) {
            # 뭐어?! 바보야! 응답이 아니라 오류겠지!
            
            die "X(";
        }
        
        my $session_info  = $self->_parse_session_info($response->decoded_content);
        my @speakers_info = $self->_parse_speaker_info($response->decoded_content);
        
        my $session  = $self->_build_session_info($session_info);
        my @speakers = map { $self->_build_speaker_info($_) } @speakers_info;
        
        return ($session, \@speakers);
    }
    
    # 크롤러 사용하기
    package Main;
    use DeviewSched::ScheduleCrawler::2048;
    
    my $parser = DeviewSched::ScheduleCrawler::2048->new(
        db_schema => $db_schema;
    );
    
    my @schedule_list = $parser->schedule_list;
    for my $session_id (@schedule_list) {
        my ($session, $speakers) = $parser->session_detail($session_id);
        printf "[Day %d Track %d] %s\n", $session->day, $session->track, $session->title;
        
        # do insert or update 
        $session->insert_or_update;
        $_->insert_or_update for @$speakers;
    }

=head1 DESCRIPTION

DeviewSched::Roles::ScheduleCrawler는ScheduleCrawler의 Moose Role입니다.

=head2 ATTRIBUTES

=over 4

=item C<_ua>

LWP::UserAgent 인스턴스입니다.

=back

=head2 VIRTUAL METHODS

이 Role을 상속하는 ScheduleCrawler 클래스는 아래 메소드가 반드시 구현되어 있어야 합니다.

=over 4

=item C<schedule_list>

스케쥴 목록을 가져옵니다. 
각 세션에 대한 id가 담긴 리스트를 반환해야 합니다.

=item C<session_detail>

세션의 상세 정보를 가져옵니다. 
(DeviewSched::Schema::Result::Session, ArrayRef[DeviewSched::Schema::Result::Speaker]) 객체를 반환해야 합니다.

=back

=head2 METHODS 

이 Role에 내장된 메소드 목록입니다.

=over 4

=item C<_request($method, $url, \%data?)> 

HTTP 요청을 보냅니다.
요청 도중 문제 발생 시 경고 출력을 하도록 wrap 한 메소드입니다.

=item C<_build_session_info($session_id, \%session_info)> 

세션 정보를 토대로 DeviewSched::Schema::Result::Session 객체를 빌드합니다.

=item C<_build_speaker_info($session_id, \%speaker_info)>

발표자 정보를 토대로 DeviewSched::Schema::Result::Speaker 객체를 빌드합니다.

=back

=head1 AUTHOR

Gyuhwan Park (unstabler) E<lt>doping.cheese@gmail.comE<gt>

=cut
