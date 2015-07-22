package DeviewSched::Schema::Result::Session;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('DeviewSession');
__PACKAGE__->add_columns(qw/year id day track session_num title description starts_at ends_at target slide_url video_url/);

__PACKAGE__->set_primary_key(qw/year id/);

__PACKAGE__->has_many(
    'speakers' => 'DeviewSched::Schema::Result::Speaker',
    {
        'foreign.session_year' => 'self.year',
        'foreign.session_id'   => 'self.id',
    },
);
