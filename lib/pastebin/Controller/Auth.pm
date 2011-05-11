package pastebin::Controller::Auth;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }
with "CatalystX::Controller::ExtJS::Direct";


use Digest::MD5 qw(md5_hex);
use Data::Dumper;

=head1 NAME

pastebin::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub logout :Path("/logout") :Args(0) {
	my ($self, $c) = @_;
	$c->logout;
	$c->response->redirect($c->uri_for('/'));
    }

sub out : Direct  {
	my ( $ self , $c ) = @_;
	$c->logout;
	$c->res->content_type("application/json");
	$c->stash(template=>"json/general.json",json=>{msg => "You have been logged out."});
}

sub in : Direct : DirectArgs(1) {
        my ($self, $c) = @_;
	my $opts = $c->req->data->[0];
	warn Dumper($opts);
	$c->res->content_type("application/json");
        # Get the username and password from form
        my $username = $opts->{username};
        my $password = $opts->{password};
	my $json;

        # If the username and password values were found in form
        if ($username && $password) {
            # Attempt to log the user in
            $password = md5_hex($password);
            if ($c->authenticate({ username => $username,
                                   password => $password  } )) {
                # If successful, then let them use the application
		$json = { msg => "You have been successfully logged in." };
            } else {
                # Set an error message
		$json =  { error    => "Bad username or password.", errno => 10 };
            }
        } else {
            # Set an error message
	    $json = { error => "Empty username or password", errno => 11} unless ($c->user_exists);
        }
        $c->stash(template => 'json/general.json',json=>$json);
    }

sub loggedin : Direct : DirectArgs(1) {
	my ( $self , $c ) = @_;
	my $li = $c->user_exists;
	my $json = { logged_in => $li };
	$c->res->content_type("application/json");
	$c->stash(template=>"json/general.json", json=>$json);
}


sub login :Path("/login") :Args(0) {
	my ($self, $c) = @_;

        # Get the username and password from form
        my $username = $c->request->params->{username};
        my $password = $c->request->params->{password};

        # If the username and password values were found in form
        if ($username && $password) {
            # Attempt to log the user in
	    $password = md5_hex($password);
            if ($c->authenticate({ username => $username,
                                   password => $password  } )) {
                # If successful, then let them use the application
                $c->response->redirect($c->uri_for('/'));
                return;
            } else {
                # Set an error message
                $c->stash(error_msg => "Bad username or password.");
            }
        } else {
            # Set an error message
            $c->stash(error_msg => "Empty username or password.")
                unless ($c->user_exists);
        }

        # If either of above don't work out, send to the login page
        $c->stash(template => 'login.html');
    }


=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
