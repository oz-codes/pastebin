package pastebin::Schema::Paste::Result::User;

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

pastebin::Schema::Paste::Result::User

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'users_id_seq'

=head2 username

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 name

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 email

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 password

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "users_id_seq",
  },
  "username",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "name",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "email",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "password",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 links

Type: has_many

Related object: L<pastebin::Schema::Paste::Result::Link>

=cut

__PACKAGE__->has_many(
  "links",
  "pastebin::Schema::Paste::Result::Link",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 notifications

Type: has_many

Related object: L<pastebin::Schema::Paste::Result::Notification>

=cut

__PACKAGE__->has_many(
  "notifications",
  "pastebin::Schema::Paste::Result::Notification",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pastes

Type: has_many

Related object: L<pastebin::Schema::Paste::Result::Paste>

=cut

__PACKAGE__->has_many(
  "pastes",
  "pastebin::Schema::Paste::Result::Paste",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<pastebin::Schema::Paste::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "pastebin::Schema::Paste::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-05-24 23:12:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:I6g54F7Am1eu6NvTpQd1MA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->has_many(map_user_role => 'pastebin::Schema::Paste::Result::UserRole', 'user_id');
__PACKAGE__->many_to_many( roles => 'map_user_role', 'role' );
__PACKAGE__->meta->make_immutable;
1;
