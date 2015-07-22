# deviewsched-backend

Deviewsched project repo for Deview 2015 

# 설치

## 의존 모듈

본 소프트웨어는 다음 Perl 모듈에 의존합니다. 사용 중이신 배포판의 패키지 관리자나 cpan / cpanm을 통해 설치하실 수 있습니다. (cpan을 통해서 system-wide로 설치하시는 것은 배포판에서 제공하는 펄 모듈 파일과 충돌이 날 수 있어 권하지 않습니다.)

[plenv](https://github.com/tokuhirom/plenv) 또는 [perlbrew](http://perlbrew.pl/)를 사용하시거나 [local::lib](https://metacpan.org/pod/local::lib)를 설정하시면 system-wide로 설치하지 않으셔도 됩니다.

- Mojolicious
- Moose
- DBI + DBD::Pg
- DBIx::Class
- Coro

## 설정 파일

저장소 내에 있는 deviewsched.conf.sample를 입맛에 맞게 편집하여 /etc/deviewsched.conf로 저장합니다.
또는, 다른 위치에 저장하신 후 DEVIEWSCHED\_BACKEND\_CONF 환경 변수를 지정합니다.

    export DEVIEWSCHED_BACKEND_CONF=$HOME/.deviewsched.conf
    
    # or ..
    
    $ DEVIEWSCHED_BACKEND_CONF=$HOME/.deviewsched.conf perl script/deview_sched daemon # !!

# 라이선스

본 소프트웨어는 MIT 라이선스를 따르고 있습니다. 

# 작성자 

Gyuhwan Park (unstabler) <doping.cheese@gmail.com>

GDG SSU
