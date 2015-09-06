package DeviewSched::FacebookAPI;
use 5.010;
use strict;
use warnings;

use base 'Facebook::Graph';

sub FB_USER_REQUIRED_FIELDS () { qw/id name picture/ }

sub reqeust {
    my $self = shift;
    my $uri  = shift;

    $uri .= '&locale=ko_KR';

    return $self->SUPER($uri, @_);
}


sub friends {
    my $self = shift;
 
    my @friends;   

    my $limit = 25;
    my $pages = 0;

    while (1) {
        my $uri = $self->query
                       ->find('me/friends')
                       ->select_fields($self->FB_USER_REQUIRED_FIELDS)
                       ->limit_results($limit)
                       ->offset_results($pages * $limit)
                       ->uri_as_string;

        my $response = $self->request($uri)->as_hashref;

        last if !defined $response || $#{$response->{data}} == -1;
        
        push @friends, @{$response->{data}};
        $pages++;
    }    


    return map { $self->remap_user_object($_) } @friends;
}

sub remap_user_object {
    my $self = shift;
    my $user = shift;
    
    $user->{picture} = (delete ($user->{picture}))->{data}->{url};

    return $user;
}

1;
