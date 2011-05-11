package pastebin::Schema::Paste::Result::Paste;

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

pastebin::Schema::Paste::Result::Paste

=cut

__PACKAGE__->table("pastes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'pastes_id_seq'

=head2 title

  data_type: 'char'
  is_nullable: 1
  size: 64

=head2 content

  data_type: 'text'
  is_nullable: 1

=head2 lang

  data_type: 'char'
  is_nullable: 1
  size: 16

=head2 poster

  data_type: 'char'
  is_nullable: 1
  size: 20

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 created_on

  data_type: 'timestamp'
  is_nullable: 1

=head2 updated_on

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "pastes_id_seq",
  },
  "title",
  { data_type => "char", is_nullable => 1, size => 64 },
  "content",
  { data_type => "text", is_nullable => 1 },
  "lang",
  { data_type => "char", is_nullable => 1, size => 16 },
  "poster",
  { data_type => "char", is_nullable => 1, size => 20 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "created_on",
  { data_type => "timestamp", is_nullable => 1 },
  "updated_on",
  { data_type => "timestamp", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 actives

Type: has_many

Related object: L<pastebin::Schema::Paste::Result::Active>

=cut

__PACKAGE__->has_many(
  "actives",
  "pastebin::Schema::Paste::Result::Active",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 forks_fork

Type: has_many

Related object: L<pastebin::Schema::Paste::Result::Fork>

=cut

__PACKAGE__->has_many(
  "forks_fork",
  "pastebin::Schema::Paste::Result::Fork",
  { "foreign.fork_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 forks_pastes

Type: has_many

Related object: L<pastebin::Schema::Paste::Result::Fork>

=cut

__PACKAGE__->has_many(
  "forks_pastes",
  "pastebin::Schema::Paste::Result::Fork",
  { "foreign.paste_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user

Type: belongs_to

Related object: L<pastebin::Schema::Paste::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "pastebin::Schema::Paste::Result::User",
  { id => "user_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 revisions

Type: has_many

Related object: L<pastebin::Schema::Paste::Result::Revision>

=cut

__PACKAGE__->has_many(
  "revisions",
  "pastebin::Schema::Paste::Result::Revision",
  { "foreign.paste_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users

Type: has_many

Related object: L<pastebin::Schema::Paste::Result::User>

=cut

__PACKAGE__->has_many(
  "users",
  "pastebin::Schema::Paste::Result::User",
  { "foreign.last_paste" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-05-11 14:33:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AkwROOksO9goqQX+ZIyQwA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
