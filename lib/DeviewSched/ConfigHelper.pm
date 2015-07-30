package DeviewSched::ConfigHelper;
use 5.010;
use strict;
use warnings;

require Exporter;

our @ISA = qw/Exporter/;
our @EXPORT_OK = qw/load_config get_config_path/;

sub get_config_path {
    if (defined $ENV{DEVIEWSCHED_BACKEND_CONF}) {
        return $ENV{DEVIEWSCHED_BACKEND_CONF};
    } else {
        return "/etc/deviewsched.conf";
    }
}


sub load_config {
    
    # 설정 파일을 어플리케이션 외부(크롤링 스크립트 등)에서 불러올 수 있도록 합니다.
    # FIXME: 설정 파일 로드할려고 Mojolicious::Lite를 외부 스크립트 내에서 불러오는게
    # 과연 좋은 방법인지는 저도 잘 모르겠습니다. 잘 아시는 분, 조언 부탁드려요! > <);

    my $app = shift;
    my $config_path = get_config_path;

    if (-e $config_path) {
        $app->plugin(config  => {file => $config_path});
    } else {
        warn sprintf "WARN: configuration file (%s) not exists", $config_path;
    }
}


1;
__END__

=encoding utf-8

=head1 NAME

DeviewSched::ConfigHelper - 설정 파일 도우미

=head1 SYNOPSIS

    use Mojolicious::Lite;
    use DeviewSched::ConfigHelper;

    # ...
    
    DeviewSched::ConfigHelper::load_config_from_outside(app);
    
    my $database_config = app->config->{database};

=cut
