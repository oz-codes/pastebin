package pastebin::Schema::Paste::Result::UserRole;

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

pastebin::Schema::Paste::Result::UserRole

=cut

__PACKAGE__->table("user_role");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 1

=head2 role_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "user_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "role_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 1,
  },
);

=head1 RELATIONS

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

=head2 role

Type: belongs_to

Related object: L<pastebin::Schema::Paste::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role",
  "pastebin::Schema::Paste::Result::Role",
  { id => "role_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-05-12 14:20:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QpZYlNxRbu/QfL4DWzdDpw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
