package DeviewSched::Schema::Result::UserAttendance;
use base qw/DeviewSched::Schema::Result/;

__PACKAGE__->table('deview_user_attendance');

__PACKAGE__->add_columns(
    id            => { data_type => 'serial' },
    user_id       => { data_type => 'bigint' },

    session_year  => { data_type => 'integer' },
    session_day   => { data_type => 'integer' },
);


__PACKAGE__->set_primary_key(qw/id/);

__PACKAGE__->belongs_to(
    'user' => 'DeviewSched::Schema::Result::User',
    {
        'foreign.id' => 'self.user_id'
    },
);

__PACKAGE__->has_many(
    'session' => 'DeviewSched::Schema::Result::Session', 
    {
        'foreign.year' => 'self.session_year',
        'foreign.day'   => 'self.session_day'
    },
);

1;
