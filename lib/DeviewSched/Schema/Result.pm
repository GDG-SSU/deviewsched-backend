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
        $hashref->{$column} = $self->$column || undef;
    } 

    return $hashref;
}

1;
