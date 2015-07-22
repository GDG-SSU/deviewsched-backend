package DeviewSched::Schema::Result::Speaker;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('DeviewSpeaker');
__PACKAGE__->add_columns(qw/id session_year session_id name organization introduction picture email website/);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
    'session' => 'DeviewSched::Schema::Result::Session', 
    {
        'foreign.year' => 'self.session_year',
        'foreign.id'   => 'self.session_id'
    },
);

