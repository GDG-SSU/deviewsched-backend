package DeviewSched::Schema::Result::Session;
use base qw/DeviewSched::Schema::Result/;

__PACKAGE__->table('deview_session');

__PACKAGE__->add_columns(
    year            => { data_type => 'numeric' },
    id              => { data_type => 'numeric' },

    day             => { data_type => 'numeric' },
    track           => { data_type => 'numeric' },
    session_num     => { data_type => 'numeric' },

    title           => { data_type => 'text' },
    description     => { data_type => 'text' },

    starts_at       => { data_type => 'timestamp' },
    ends_at         => { data_type => 'timestamp' },

    target          => { data_type => 'text', __PACKAGE__->NULLABLE },
    slide_url       => { data_type => 'text', __PACKAGE__->NULLABLE },
    video_url       => { data_type => 'text', __PACKAGE__->NULLABLE },
); 

__PACKAGE__->set_primary_key(qw/year id/);

__PACKAGE__->has_many(
    'speakers' => 'DeviewSched::Schema::Result::Speaker',
    {
        'foreign.session_year' => 'self.year',
        'foreign.session_id'   => 'self.id',
    },
);

1;
