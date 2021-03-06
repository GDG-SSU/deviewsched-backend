package DeviewSched::Schema::Result::Speaker;
use base qw/DeviewSched::Schema::Result/;

__PACKAGE__->table('deview_speaker');

__PACKAGE__->add_columns(

    # serial == auto_increment integer
    id              => { data_type => 'serial' }, 
    session_year    => { data_type => 'integer' },
    session_id      => { data_type => 'integer' },

    name            => { data_type => 'text' },
    organization    => { data_type => 'text' },
    introduction    => { data_type => 'text' },

    picture         => { data_type => 'text', __PACKAGE__->NULLABLE },

    email           => { data_type => 'text', __PACKAGE__->NULLABLE },
    website_url     => { data_type => 'text', __PACKAGE__->NULLABLE },
    facebook_url    => { data_type => 'text', __PACKAGE__->NULLABLE },
    github_url      => { data_type => 'text', __PACKAGE__->NULLABLE },

);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
    'session' => 'DeviewSched::Schema::Result::Session', 
    {
        'foreign.year' => 'self.session_year',
        'foreign.id'   => 'self.session_id'
    },
);

1;
