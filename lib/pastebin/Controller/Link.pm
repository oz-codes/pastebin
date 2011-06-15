package pastebin::Controller::Link;
use Moose;
use namespace::autoclean;

use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }
with "CatalystX::Controller::ExtJS::Direct";

=head1 NAME

pastebin::Controller::Paste - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched pastebin::Controller::Paste in Paste.');
}

sub create :Direct :DirectArgs(1) {
	my ($self, $c) = @_;
	my $opts = $c->req->data->[0];
	$c->res->content_type("application/json");
	my $link = $opts->{link};
	my $shortlink = $opts->{shortlink};
	my $json;
	if(!defined $link) {
		$json = { error => "You did not provide a link." };
	} elsif ($link !~ /(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:\/~\+#]*[\w\-\@?^=%&amp;\/~\+#])?/) {
		$json = { error => "That didn't look like a valid URL to me." };
	} else {
		if(!defined $shortlink) {
			my $buf;
			do {
				do {
					my $chr;
					do {
						$chr = chr(int(rand(126)+1))
					} while ($chr !~ /[A-Z0-9]/i);
					$buf .= $chr;
				} while (length ($buf) < 8);
			} while (defined $c->model("Paste::link")->find({shortlink => $shortlink}));
			$shortlink = $buf;
		} else {
			if(defined $c->model("Paste::link")->find({shortlink => $shortlink})) {
				$json = { error => "That short link you chose has already been taken." };
			} else {
				my $linkdb = $c->model("Paste::link");
				my $uid;
				if($c->user_exists) {
					$uid = $c->session->{__user}->{id};
				}
				$linkdb->create({
					shortlink 	=> 		$shortlink,
					link		=>		$link,
					user_id		=>		$uid,
					created_on	=>		time
				});
				$json = { msg => "Your link has been created. You can visit it here: http://hg.fr.am:3002/l/$shortlink" };
			}
		}
	}
	$c->stash(template => "json/general.json", json=>$json);
}

sub view :Path("/l") :Args(1) {
	my ($self, $c, $link) = @_;
	my $lx = $c->model("Paste::link")->find({shortlink => $link});
	if(!defined $lx) {
		$c->stash(template=>"nosuchlink.html",link=>$link);
	} else {
		my $fulllink = $lx->get_column("link");
		$c->res->redirect($fulllink,302);
		$c->detach();
	}
}			

sub list :Direct {
	my ($self, $c) = @_;
	$c->res->content_type("application/json");
	my $json;
	if($c->user_exists) {
		my @ldb = $c->model("Paste::link")->search({user_id => $c->session->{__user}->{id}});
		my $arr = &jarr(\@ldb);
		$json = { links => $arr };
	} else {
		$json = { error => "You aren't logged in." };
	}
	$c->stash(template=>"json/general.json",json=>$json);
} 

sub jarr : Method {
        my $a = shift;
        my @arr = @{$a};
        #warn "got an array with " . ($#arr+1) . " elements\n";
        my @ret;
        foreach my $ent (@arr) {
                #warn "Got a new entry: $ent\n";
                #warn Dumper($ent);
                my %d = %{$ent->{_column_data}};
                my $temp;
                while(my ($k, $v) = each(%d)) {
                        $v = undef if !defined $v;
                        #warn "\$temp->{$k} = $v\n";
                        $temp->{$k} = $v;
                }
                push @ret, $temp;
        }
        return \@ret;
}



__PACKAGE__->meta->make_immutable;

1;
