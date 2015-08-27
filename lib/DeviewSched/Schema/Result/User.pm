package DeviewSched::Schema::Result::User;
use base qw/DeviewSched::Schema::Result/;

__PACKAGE__->table('deview_user');

__PACKAGE__->add_columns(
    # facebook user id
    id            => { data_type => 'bigint' },
    fb_token      => { data_type => 'text' },

    name          => { data_type => 'text' },
    picture       => { data_type => 'text' },
);

__PACKAGE__->set_primary_key(qw/id/);

__PACKAGE__->has_many(
    'schedules' => 'DeviewSched::Schema::Result::UserSchedule',
    {
        'foreign.user_id' => 'self.id'
    },
);

1;
