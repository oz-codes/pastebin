package pastebin::Controller::API;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }
extends q(CatalystX::Controller::ExtJS::Direct::API);

=head1 NAME

pastebin::Controller::API - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut



=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
