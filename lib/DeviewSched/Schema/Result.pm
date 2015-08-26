package DeviewSched::Schema::Result;

use Scalar::Util qw/looks_like_number/;
use base qw/DBIx::Class::Core/;

sub NULLABLE () { (is_nullable => 1) }

sub serialize {
    my $self = shift;

    return $self->serialize_columns([$self->columns]);
} 

sub serialize_columns {
    my $self    = shift;
    my @columns = @{ (shift || []) };

    my $hashref = {};

    for my $column (@columns) {
        my $value = $self->$column || undef;

        # DateTime 객체인 경우 타임스탬프로 변환
        $value = $value->epoch if ref $value eq "DateTime";

        $hashref->{$column} = $value;
    } 

    return $hashref;
}

1;
