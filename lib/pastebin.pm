package pastebin;
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

    Authentication
    Email
    Observe

    Session
    Session::Store::FastMmap
    Session::State::Cookie
/;
use Data::Dumper;
use CatalystX::RoleApplicator;
use JSON;
use Syntax::Highlight::Engine::Kate;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in pastebin.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'pastebin',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
);
    __PACKAGE__->apply_request_class_roles(qw(
        Catalyst::TraitFor::Request::XMLHttpRequest
    ));



__PACKAGE__->config->{'Plugin::Authentication'} = {
	default => {
		class		=>	'SimpleDB',
		user_model	=>	'Paste::user',
		password_type	=>	'clear'
	}
};


# Start the application
__PACKAGE__->setup();

sub dispatch_hook {
        my ( $c, $event, @args ) = @_;
	my $kate =  new Syntax::Highlight::Engine::Kate(
		    language => 'Perl',
		    substitutions => {
		       "<" => "&lt;",
		       ">" => "&gt;",
		       "&" => "&amp;",
		       " " => "&nbsp;",
		       "\t" => "&nbsp;&nbsp;&nbsp;",
		       "\n" => "<BR>\n",
		    },
		    format_table => {
		       Alert => ["<font color=\"#0000ff\">", "</font>"],
		       BaseN => ["<font color=\"#007f00\">", "</font>"],
		       BString => ["<font color=\"#c9a7ff\">", "</font>"],
		       Char => ["<font color=\"#ff00ff\">", "</font>"],
		       Comment => ["<font color=\"#7f7f7f\"><i>", "</i></font>"],
		       DataType => ["<font color=\"#0000ff\">", "</font>"],
		       DecVal => ["<font color=\"#00007f\">", "</font>"],
		       Error => ["<font color=\"#ff0000\"><b><i>", "</i></b></font>"],
		       Float => ["<font color=\"#00007f\">", "</font>"],
		       Function => ["<font color=\"#007f00\">", "</font>"],
		       IString => ["<font color=\"#ff0000\">", ""],
		       Keyword => ["<b>", "</b>"],
		       Normal => ["", ""],
		       Operator => ["<font color=\"#ffa500\">", "</font>"],
		       Others => ["<font color=\"#b03060\">", "</font>"],
		       RegionMarker => ["<font color=\"#96b9ff\"><i>", "</i></font>"],
		       Reserved => ["<font color=\"#9b30ff\"><b>", "</b></font>"],
		       String => ["<font color=\"#ff0000\">", "</font>"],
		       Variable => ["<font color=\"#0000ff\"><b>", "</b></font>"],
		       Warning => ["<font color=\"#0000ff\"><b><i>", "</b></i></font>"],
		    },
		 );
	$c->stash->{kate} = $kate;
	$c->stash->{pastes} = $c->model("Paste::pastes");
	$c->stash->{forks} = $c->model("Paste::forks");
}

__PACKAGE__->add_subscriber("finalize",\&dispatch_hook);

=head1 NAME

pastebin - Catalyst based application

=head1 SYNOPSIS

    script/pastebin_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<pastebin::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
