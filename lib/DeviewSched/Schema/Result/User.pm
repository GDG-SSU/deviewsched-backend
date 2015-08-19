package DeviewSched::Schema::Result::User;
use base qw/DeviewSched::Schema::Result/;

__PACKAGE__->table('deview_user');

__PACKAGE__->add_columns(
    # facebook user id
    id            => { data_type => 'bigint' },

    name          => { data_type => 'text' },
    picture       => { data_type => 'text' },
);



__PACKAGE__->set_primary_key(qw/id/);

1;
