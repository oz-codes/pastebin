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
	$c->_save_session();
	$c->response->redirect($c->uri_for('/'));
    }

sub out : Direct  {
	my ( $ self , $c ) = @_;
	$c->logout;
	$c->_save_session();
	$c->res->content_type("application/json");
	$c->stash(template=>"json/general.json",json=>{msg => "You have been logged out."});
}

sub in : Direct : DirectArgs(1) {
        my ($self, $c) = @_;
	my $opts = $c->req->data->[0];
	$c->res->content_type("application/json");
        # Get the username and password from form
        my $username = $opts->{username};
        my $password = $opts->{password};
	my $json;

        # If the username and password values were found in form
        if ($username && $password) {
	    $password = md5_hex($password);
            # Attempt to log the user in
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
	$c->_save_session();
        $c->stash(template => 'json/general.json',json=>$json);
    }

sub loggedin : Direct : DirectArgs(1) {
	my ( $self , $c ) = @_;
	open my $f, ">session";
	print $f Dumper($c->session->{__user});
	close $f;
	my $checks = (defined $c->session->{checks})?$c->session->{checks}:1;
	warn "checks = $checks";
	
	my $li;
	if($c->user_exists()) {
		$li = 1;
	} else {
		$li = 0;
	}		
	my $json = { loggedin => $li };
	$c->res->content_type("application/json");
	$c->session->{checks} = $checks+1;
	$c->_save_session();
	$c->stash(template=>"json/general.json", json=>$json);
}

sub register :Direct :DirectArgs(1) {
	my ( $self , $c ) = @_;
	my $opts = $c->req->data->[0];
	$c->res->content_type("application/json");
	warn Dumper($opts);
	my $username = $opts->{username};
	my $email = @{$opts->{email}};
	my ($pass, $passc)   = @{$opts->{password}};
	my $json;
	if(!defined $username) {
		$json = { error => "You did not provide a username.", errno => 20 };
	}
	elsif(!defined $email) {
		$json = { error => "You did not provide an email address.", errno => 21};
	} 
	elsif (!defined $pass) {
		$json = { error => "You did not provide a password.", errno => 22 };
	} 
	elsif(!defined $passc) {
		$json = { error => "You did not provide the password confirmation", errno => 23 }
	} elsif( length($username) > 12) {
		$json = { error => "The username you picked was too long. It should be 12 characters or less.", errno => 24};
	} elsif( $pass ne $passc   ) {
		$json = { error => "The passwords that you provided did not match.", errno => 25 };
	} elsif ( $email !~ /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i ) {
		$json = { error => "The email address you provided did not appear to be a valid email address.", errno => 26 };
	} elsif ( $username !~ /[\w\.\-_]{3,12}/ ) {
		$json = { error => "The username that you provided did not appear to be a valid one.", errno => 27 };
	} elsif ( length($username) < 3) {
		$json = { error => "The username you picked was too short. It should be at least 3 characters.", errno=>28};   } 
	elsif( defined $c->model("Paste::user")->find({email => $email}) ) {
		$json = { error => "The email address you provided is already in use.", errno => 29 };
	}
	elsif( defined $c->model("Paste::user")->find({username => $username}) ) {
		$json = { error => "The username you picked is already in use.", errno => 30 };
	}
	else {
		my $row = $c->model("Paste::user")->create({
				username => $username,
				email    => $email,
				password => md5_hex($pass),
		});
		my $id = $row->{_column_data}->{id};
		$c->model("Paste::user_role")->create({
			user_id => $id,
			role_id => 1
		});
		$json = { msg => "Your account was successfully created." };
	}
	$c->stash(template=>"json/general.json",json=>$json);
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
	$c->_save_session();
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
