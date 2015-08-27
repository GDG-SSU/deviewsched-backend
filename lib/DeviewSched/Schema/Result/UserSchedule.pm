package DeviewSched::Schema::Result::UserSchedule;
use base qw/DeviewSched::Schema::Result/;

__PACKAGE__->table('deview_user_schedule');

__PACKAGE__->add_columns(
    id            => { data_type => 'serial' },
    user_id       => { data_type => 'bigint' },

    session_year  => { data_type => 'numeric' },
    session_id    => { data_type => 'numeric' },
);


__PACKAGE__->set_primary_key(qw/id/);

__PACKAGE__->belongs_to(
    'user' => 'DeviewSched::Schema::Result::User',
    {
        'foreign.id' => 'self.user_id'
    },
);

__PACKAGE__->belongs_to(
    'session' => 'DeviewSched::Schema::Result::Session', 
    {
        'foreign.year' => 'self.session_year',
        'foreign.id'   => 'self.session_id'
    },
);

1;
