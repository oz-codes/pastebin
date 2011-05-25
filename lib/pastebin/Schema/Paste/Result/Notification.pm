package pastebin::Schema::Paste::Result::Notification;

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

pastebin::Schema::Paste::Result::Notification

=cut

__PACKAGE__->table("notifications");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'notifications_id_seq'

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 message

  data_type: 'text'
  is_nullable: 1

=head2 created_on

  data_type: 'integer'
  is_nullable: 1

=head2 sent_on

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "notifications_id_seq",
  },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "message",
  { data_type => "text", is_nullable => 1 },
  "created_on",
  { data_type => "integer", is_nullable => 1 },
  "sent_on",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-05-24 18:33:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:d/iDxnH53lPswLOlYCxQTQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;