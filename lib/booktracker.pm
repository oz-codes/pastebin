package booktracker;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;


# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    Session
    Session::Store::FastMmap
    Session::State::Cookie
    Email
    Observe
/;
use Data::Dumper;

use CatalystX::RoleApplicator;
use JSON;




extends 'Catalyst';


our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in booktracker.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'booktracker',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
);
__PACKAGE__->config->{email} = ['Sendmail'];

    __PACKAGE__->apply_request_class_roles(qw(
        Catalyst::TraitFor::Request::XMLHttpRequest
    ));



# Start the application
__PACKAGE__->setup();

sub dispatch_hook {
        my ( $c, $event, @args ) = @_;
        my @rs = $c->model("BookDB::active")->all;
	#warn "In dispatch hook";
	#warn Dumper($c->session);

        foreach my $res (@rs) {
                $res->delete if (($res->{_column_data}->{chronos} < time-1) && ($res->{_column_data}->{staff_id} == $c->session->{id})) || $res->{_column_data}->{chronos} < time - 60;
        }
        if(defined $c->session->{id}) {
               $c->model("BookDB::active")->create({staff_id=>$c->session->{id},chronos=>time});
        }
}

booktracker->add_subscriber("dispatch",\&dispatch_hook);



=head1 NAME

booktracker - Catalyst based application

=head1 SYNOPSIS

    script/booktracker_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<booktracker::Controller::Root>, L<Catalyst>

=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
