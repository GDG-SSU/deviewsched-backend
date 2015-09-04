package DeviewSched::Controller::Sessions;
use utf8;

use Mojo::Base 'DeviewSched::Controller';
use Time::HiRes qw/time/;

use DeviewSched::SessionListUtils 
    qw/COLUMNS_LIST_SESSIONS_SESSION COLUMNS_LIST_SESSIONS_SPEAKER/;

sub list_years {
    my $self = shift;
    my $resultset = $self->db_schema->resultset('Session');

    my @result = map { $_->year } $resultset->search(undef, {
        columns => ['year'],
        distinct => 1,
    });
    
    $self->render(json => {
        years_available => \@result 
    });
}

sub list_sessions {
    my $self = shift;
    my $resultset = $self->db_schema->resultset('Session');

    my @data;

    my @sessions = $resultset->search({
        year => $self->stash('year'),   
    }, {

        select => [
            (map { "me.$_" } COLUMNS_LIST_SESSIONS_SESSION),
            (map { "speakers.$_" } COLUMNS_LIST_SESSIONS_SPEAKER),
        ],

        join     => 'speakers',
        prefetch => 'speakers',
        order_by => {
            -asc => 'starts_at'
        }
    });

     
    $self->render(json => {
        days => DeviewSched::SessionListUtils::classify_by_days(\@sessions)
    });
}

sub session_details {
    my $self = shift;
    my $resultset = $self->db_schema->resultset('Session');
    
    my ($session) = $resultset->search({
        year => $self->stash('year'),
        id   => $self->stash('id'),
    });

    unless (defined $session) {
        return $self->fail($self->FAIL_RESOURCE_NOT_AVAILABLE);
    }

    $self->render(json => $session->serialize);
}

sub speakers {
    my $self = shift;
    my $resultset = $self->db_schema->resultset('Speaker');

    my @speakers = map { $_->serialize } $resultset->search({
        session_year => $self->stash('year'),
        session_id   => $self->stash('id'),    
    });

    $self->render(json => {
        year => $self->stash('year'),
        id   => $self->stash('id'),

        speakers => \@speakers
    });
} 

1;
__END__

=encoding utf-8

=head1 NAME

DeviewSched::Controller::Sessions - Deview 세션과 관련된 컨트롤러

=head1 ENDPOINTS

=over 4

=item C<GET /years>

세션 정보가 사용 가능한 년도의 목록을 반환합니다.
    
    { "years_available": [2014, 2015] }

=item C<GET /%year%/list>

C<%year%> 년도의 세션 목록을 출력합니다.

=item C<GET /%year%/%session_id%>

C<%year%> 년도의 ID가 C<%session_id%>인 세션의 정보를 출력합니다.

=item C<GET /%year%/%session_id%/speakers>

C<%year%> 년도의 ID가 C<%session_id%>인 세션의 발표자 목록을 출력합니다. 

=back
