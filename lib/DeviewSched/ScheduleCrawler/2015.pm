package DeviewSched::ScheduleCrawler::2015;
use 5.010;
use utf8;
use strict;
use warnings;

use DateTime;
use LWP::UserAgent;
use JSON qw/decode_json/;

use Data::Dumper;

use Moose;

with 'DeviewSched::ScheduleCrawler';

sub URL_TIMETABLE () { 'http://deview.kr/2015/timetable' } 

sub YEAR       () { 2015 }
sub DEFAULT_TZ () { 'Asia/Seoul' }

sub PROGRAM_TYPE_REGISTER () { "REGISTER" }
sub PROGRAM_TYPE_KEYNOTE  () { "KEYNOTE"  }
sub PROGRAM_TYPE_SESSION  () { "SESSION"  }
sub PROGRAM_TYPE_BOF      () { "BOF"      } # BOF는 뭐지?!

sub REBUILD_DATA_SESSION_INFO () {
    {
        'name'    => 'title',
        'content' => 'description',
    }
}

sub REBUILD_DATA_SPEAKER_INFO () {
    {
        'belong'  => 'organization',
        'contact' => 'email',
        'profileImageUrl' => 'picture',

        'id'      => undef
    }
}

has '_cache_raw_timetable' => (
    is  => 'rw',
    isa => 'HashRef'
);

has '_cache_category_list' => (
    is  => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
);

has '_cache_schedule_list' => (
    is  => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
);

sub BUILD {
    my $self = shift;

    eval {
        $self->_refresh_cache;
    };

    if ($@) {
        # TODO: 상세한 오류 메시지
        die $@;
    }
}

sub schedule_list {
    my $self = shift;

    my @schedule_list = map { $_->{id} } @{ $self->_cache_schedule_list };
    return @schedule_list;
}

sub session_detail {
    my $self = shift;
    my $session_id = shift;

    my ($session_info) = grep { $_->{id} == $session_id } @{ $self->_cache_schedule_list };

    my $session  = $self->_build_session_info(
        $session_id,
        $self->_rebuild_hash($session_info, REBUILD_DATA_SESSION_INFO)
    );

    my @speakers = map { 
        $self->_build_speaker_info(
            $session_id,
            $self->_rebuild_hash($_, REBUILD_DATA_SPEAKER_INFO)
        );
    } @{ $session_info->{speakerList} };
    
    return ($session, \@speakers);
}

sub _rebuild_hash {
    my $self = shift;
    
    # copy hash contents
    my $hashref    = { %{ (shift) } };
    my $remap_data = shift;

    while (my ($key, $newkey) = each %$remap_data) {
        if ($hashref->{$key}) {
            my $value = delete $hashref->{$key};
            $hashref->{$newkey} = $value if defined $newkey;
        }
    }

    return $hashref;
}

sub _refresh_cache {
    my $self = shift;

    unless ($self->_cache_raw_timetable) {
        # 타임테이블이 캐싱되지 않음 
        $self->_cache_raw_timetable($self->_request_raw_timetable);
        $self->_parse_raw_timetable($self->_cache_raw_timetable);

    }
}

sub _request_raw_timetable {
    my $self = shift;
    
    my $res = $self->_request('get', URL_TIMETABLE);
    if ($res->is_success) {
        my $timetable = eval { decode_json $res->decoded_content };
        die "json_decode failed: $@" if $@;

        return $timetable unless $@;
    }
}

sub _parse_raw_timetable {
    my $self = shift;
    my $timetable = shift;
    
    my @day_list = @{ $timetable->{dayList} };
    
    map { $self->_parse_raw_day($_) } @day_list; 
}

sub _parse_raw_day {
    my $self = shift;
    my $day  = shift;

    my $day_id = $day->{id};
    my @program_list = @{ $day->{programList} };

    my @schedule_list;

    for my $program (@program_list) {

        # TODO: 스케쥴 타입 컬럼을 따로 만들어서 세션, 등록, 키노트 등으로 분류해야 할려나..
        #       환장하겠군! > <);
        #
        # 일단은 세션만 가져오도록 합니다 
        
        # 시작 / 종료 시간        
        my ($starts_at, $ends_at) = $self->_parse_raw_program_time($day, $program); 

        if ($program->{feature} eq PROGRAM_TYPE_SESSION) {
            my $track = 1;
            my @raw_session_list = @{ $program->{sessionList} };

            for my $session (@raw_session_list) {
                

                # 정보 설정
                $session->{track}     = $track++;
                $session->{day}       = $day_id;

                $session->{starts_at} = $starts_at;
                $session->{ends_at}   = $ends_at;

                push @schedule_list, $session; 
            }
        }
    }

    push @{ $self->_cache_schedule_list }, @schedule_list;
}

sub _parse_session_num {
    # maybe useless
    my $self = shift;
    my $title = shift;

    return $title =~ m/^세션 (\d+)$/;
}

sub _parse_raw_program_time {
    my $self = shift;
    my ($day, $program) = @_;
    
    my ($date_month, $date_day) = $day->{date} =~ m/^(\d{1,2})\.(\d{1,2})\s+\w+$/;
    
    return map {
        my ($hour, $min) = $_ =~ m/(\d{2}):(\d{2})/; 
        DateTime->new (
            year  => $self->YEAR,
            month => $date_month,
            day   => $date_day,

            hour   => $hour,
            minute => $min,

            time_zone => DEFAULT_TZ
        ); 
    } ($program->{startTime}, $program->{endTime});
    
}

1;
__END__

=encoding utf-8

