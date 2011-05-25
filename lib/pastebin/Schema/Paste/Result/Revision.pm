package pastebin::Schema::Paste::Result::Revision;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

pastebin::Schema::Paste::Result::Revision

=cut

__PACKAGE__->table("revisions");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'revisions_id_seq'

=head2 paste_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 revision_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 version

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "revisions_id_seq",
  },
  "paste_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "revision_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "version",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 paste

Type: belongs_to

Related object: L<pastebin::Schema::Paste::Result::Paste>

=cut

__PACKAGE__->belongs_to(
  "paste",
  "pastebin::Schema::Paste::Result::Paste",
  { id => "paste_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 revision

Type: belongs_to

Related object: L<pastebin::Schema::Paste::Result::Paste>

=cut

__PACKAGE__->belongs_to(
  "revision",
  "pastebin::Schema::Paste::Result::Paste",
  { id => "revision_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-05-24 18:13:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Jco6xBq0LfuOVSiEHmN+LA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
