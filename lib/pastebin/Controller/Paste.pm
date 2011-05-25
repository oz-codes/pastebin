package pastebin::Controller::Paste;
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

my $kate =  new Syntax::Highlight::Engine::Kate(
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

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched pastebin::Controller::Paste in Paste.');
}

sub languages :Direct {
	my ( $self, $c ) = @_;
	my @langs = $kate->syntaxes;
	
	my $json;
	my @temp;
	foreach my $ent (@langs) {
		while(my ($name, $id) = each(%$ent)) {
			my $hash = { language => $name, name => $id };
			push @temp,$hash;
		}
	}
	@temp = sort { uc($a->{language}) cmp uc($b->{language})} @temp;
	$c->res->content_type("application/json");
	$c->stash(template=>"json/general.json",json=>\@temp);
}

sub create :Direct :DirectArgs(1)  {
	my ( $self , $c ) = @_;
	my $opts = $c->req->data->[0];
	my $title = $opts->{title};
	my $post = $opts->{post};
	my $lang = $opts->{lang};
	my $json;
	my $id;
	my $uid;
	if(!defined $title) {
		$json = { error => "You did not provide a title.", errno => 1 };
	} elsif(!defined $post) {
		$json = { error => "You did not provide any content.", errno => 2};
	} elsif(!defined $lang) {
		$json = { error => "You did not provide a language.", errno => 3};
	} elsif(!defined $kate->syntaxes->{$lang}) {
		$json = { error => "The language you provided does not exist", errno => 4};
	} elsif(!$c->user_exists) {
		$json = { error => "You are not currently logged in.", errno => 5};
	} else {
		my $language = $kate->syntaxes->{$lang};
		chomp($language);
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
		my $datetime = sprintf "%4d-%02d-%02d %02d:%02d:%02d\n",$year+1900,$mon+1,$mday,$hour,$min,$sec;
		my $db = $c->model("Paste::paste");
		if(defined $c->session->{"__user"}) {
			$uid = $c->session->{"__user"}->{"id"};
		} else {
			$uid = undef;
		}
		my $row = $db->create({
			title => $title,
			content => $post,
			lang => $lang,
			created_on => $datetime,
			updated_on => $datetime,
			user_id	   => $uid
			});
		$id = $row->{_column_data}->{id};
		$json = { msg => "Your post was successfully made. You can view it using the saved pastes tab." };
	}
	$c->res->content_type("application/json");
	$c->stash(template=>"json/general.json",json=>$json);
}

sub createFork :Direct :DirectArgs(1) {
        my ( $self , $c ) = @_;
        my $opts = $c->req->data->[0];
        my $title = $opts->{title};
        my $post = $opts->{post};
        my $lang = $opts->{lang};
	my $oldId = $opts->{oldId};
        my $json;
        my $id;
        my $uid;
        if(!defined $title) {
                $json = { error => "You did not provide a title.", errno => 1 };
        } elsif(!defined $post) {
                $json = { error => "You did not provide any content.", errno => 2};
        } elsif(!defined $lang) {
                $json = { error => "You did not provide a language.", errno => 3};
        } elsif(!defined $kate->syntaxes->{$lang}) {
                $json = { error => "The language you provided does not exist", errno => 4};
	} elsif(!defined $oldId) {
		$json = { error => "I don't know how you got this message. Seriously.", errno=>-1 };
        } elsif(!$c->user_exists) {
		$json = { error => "You are not currently logged in.", errno=> 5};
	} else {
                my $language = $kate->syntaxes->{$lang};
                chomp($language);
                my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
                my $datetime = sprintf "%4d-%02d-%02d %02d:%02d:%02d\n",$year+1900,$mon+1,$mday,$hour,$min,$sec;
                my $db = $c->model("Paste::paste");
                if(defined $c->session->{"__user"}) {
                        $uid = $c->session->{"__user"}->{"id"};
                } else {
                        $uid = undef;
                }
                my $row = $db->create({
                        title => $title,
                        content => $post,
                        lang => $lang,
                        created_on => $datetime,
                        updated_on => $datetime,
                        user_id    => $uid
                        });
                $id = $row->{_column_data}->{id};
		$c->model("Paste::fork")->create({paste_id => $oldId, fork_id => $id});
                $json = { msg => "Your post was successfully made. You can view it using the saved pastes tab." };
        }
        $c->res->content_type("application/json");
        $c->stash(template=>"json/general.json",json=>$json);
}

sub createRev :Direct :DirectArgs(1) {
        my ( $self , $c ) = @_;
        my $opts = $c->req->data->[0];
        my $title = $opts->{title};
        my $post = $opts->{post};
        my $lang = $opts->{lang};
        my $oldId = $opts->{oldId};
        my $json;
        my $id;
        my $uid;
        if(!defined $post) {
                $json = { error => "You did not provide any content.", errno => 2};
        } elsif(!defined $oldId) {
                $json = { error => "I don't know how you got this message. Seriously.", errno=>-1 };
        } elsif(!$c->user_exists || !defined $c->session->{"__user"}) {
		$json = { error => "You are not currently logged in.", errno => 5 };
	} else {
                my $language = $kate->syntaxes->{$lang};
                chomp($language);
                my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
                my $datetime = sprintf "%4d-%02d-%02d %02d:%02d:%02d\n",$year+1900,$mon+1,$mday,$hour,$min,$sec;
                my $db = $c->model("Paste::paste");
		my $version = $c->model("Paste::revision")->search({paste_id => $oldId});
		$version = defined $version ? $version+1 : 1;
                if(defined $c->session->{"__user"}) {
                        $uid = $c->session->{"__user"}->{"id"};
			warn 
                } else {
                        $uid = undef;
                }
                my $row = $db->create({
                        title => $title,
                        content => $post,
                        lang => $lang,
                        created_on => $datetime,
                        updated_on => $datetime,
                        user_id    => $uid
                        });
                $id = $row->{_column_data}->{id};
                $c->model("Paste::revision")->create({paste_id => $oldId, revision_id => $id, version => $version });
                $json = { msg => "Your post was successfully made. You can view it using the saved pastes tab." };
        }
        $c->res->content_type("application/json");
        $c->stash(template=>"json/general.json",json=>$json);
}


sub pastes :Direct :DirectArgs(1) {
	my ( $self, $c) = @_;
	my $opts = $c->req->data->[0];
	my $start = $opts->{start};
	my $limit = $opts->{limit};
	my @rs = $c->model("Paste::paste")->search({})->slice($start,$limit);
	my $json = &jarr(\@rs);
	$c->res->content_type("application/json");
	$c->stash(template=>"json/pastes.json",json=>$json);
}

sub hasRevision :Direct :DirectArgs(1) {
	my ( $self, $c) = @_;
	my $opts = $c->req->data->[0];
	my $id = $opts->{id};
	$c->res->content_type("application/json");
	my @q = $c->model("Paste::revision")->search({paste_id => $id});
	my $json = {answer => $#q+1};
	warn Dumper($json);
	$c->stash(template=>"json/general.json",json=>$json);
}

sub hasrev :Method {
        my ( $self, $c, $id) = @_;
        my @q = $c->model("Paste::revision")->search({paste_id => $id});
	return $#q+1;
}


sub isrev :Method {
	my ($self, $c, $id) = @_;
	open my $f, ">debug";
	print $f "checking to see if $id is a rev\n";
	my $rs = $c->model("Paste::revision")->find({revision_id => $id});
	my $ret;
	if(defined $rs) {
		print $f "$id is a revision\n";
		print $f "dump of rs\n";
		print $f Dumper($rs);
		$ret = $rs->get_column("paste_id");
	} else {
		print $f "$id is not a revision\n";
		$ret = -1;
	}
	print $f "returning $ret from isrev\n";
	close $f;
	return $ret;
}
		

sub isRevision :Direct :DirectArgs(1) {
	my ( $self, $c ) = @_;
	my $opts = $c->req->data->[0];
	my $id = $opts->{id};
	$c->res->content_type("application/json");
	my $rs = $c->model("Paste::revision")->find({revision_id => $id});
	my $json;
	if(defined $rs) {
		$json = {answer => $rs->get_column("paste_id")};
	} else {
		$json = {answer => -1};
	}
	#/warn Dumper($rs);
	$c->stash(template=>"json/general.json",json=>$json);
}

sub getRevisions :Direct :DirectArgs(1) {
	my ($self,$c) = @_;
	my $opts = $c->req->data->[0];
	my $id = $opts->{id};
	$c->res->content_type("application/json");
	my $json;
	my @arrr = $c->model("Paste::paste")->search({id => $id});
	my $arar = &jarr(\@arrr);
	push @$json,$arar->[0];
	my @r = $c->model("Paste::revision")->search({paste_id => $id});
	for(my $i = 0; $i < $#r+1; $i++) {
		my $rev = $r[$i];
		next if !defined $rev->{_column_data}->{revision_id};
		my @arr = $c->model("Paste::paste")->find({id => $rev->{_column_data}->{revision_id}});
		my $arr = &jarr(\@arr);
		push @$json,$arr->[0];
	}	
	open my $f, ">rrrr";
	print $f Dumper($json);
	close $f;
	$c->stash(template=>"json/revs.json",json=>$json);
}


sub getPaste : Direct : DirectArgs(1) {
	my ( $self , $c ) = @_;
	my $opts = $c->req->data->[0];
	my $json;
	my @content;
	my $id;
	my $out;
	if(ref $opts eq "HASH") {
		$id = $opts->{id};
	} else {
		$id = $opts;
	}
	if(!defined $opts) {
		$json = { error => "No ID was provided.", errno=>7};
	} else {
		my @row = $c->model("Paste::paste")->find({id => $id});
		my $rev = $c->model("Paste::revision")->find({revision_id=>$id});
		if($rev) {
			my @b = $c->model("Paste::revision")->search({paste_id=>$rev->{_column_data}->{paste_id}});
			my $r;
			for(my $i=0;$i<$#b+1;$i++) {
				warn $i;
				$r = $i if $b[$i]->{_column_data}->{revision_id} == $id;
			}
			$rev = defined $r ? $r+1 : 0;
		}
		if($#row<0) {
			$json = { error => "I couldn't find that paste.", errno => 8 };
		} else {
			$json = &jarr(\@row);
			$json = $json->[0];
			@content = split /\n/,$json->{content};
			$json->{lang} =~ s/\s*$//ig;
			$kate->language($json->{lang});
			foreach my $line (@content) {
				$out .= $kate->highlightText($line)."<br />";	
			}		
			$json->{content} = $kate->highlightText($json->{content});
			$json->{revision} = $rev;	
		}
	}
	$c->res->content_type("application/json");
	$c->stash(template=>"json/general.json",json=>$json);		
}

sub delete : Direct : DirectArgs(1) {
	my ($self, $c) = @_;
	$c->res->content_type("application/json");
	my $opts = $c->req->data->[0];
	my $pid = $opts->{"pid"};
	my $json;
	if(!defined $pid) {
		$json = { error => "You did not provide a post ID." };
	} else {
		my $paste = $c->model("Paste::paste")->find({id => $pid});
		my $title = $paste->{_column_data}->{title};
		my $oid = $paste->{_column_data}->{user_id};
		my $candel;
		my $rev;
		my $msg;
		if((($rev = $self->isrev($c,$pid)) > -1)) {
			my $rid = $c->model("Paste::revision")->find({revision_id => $pid})->get_column("id");
			my @revs = $c->model("Paste::revision")->search_literal("paste_id = ? AND id >= ?", ($rev, $rid));	
			if($c->check_user_roles("admin")) {
				my @del;
				foreach my $rev(@revs) {
					my $paste = $c->model("Paste::paste")->find({id => $rev->get_column("revision_id")});
					push @del, $paste;
				}
				foreach my $p (@del) {
					my $uid = $p->get_column("user_id");
					my $name = $p->get_column("title");
					my $id = $p->get_column("id");
					my $time = time;
					$c->model("Paste::notification")->create({
						user_id => $uid,
						message => "Your paste, $name (id: $id), has been deleted.",
						created_on => $time
					});
					warn "Deleted $name";
					$msg .= "Deleted: $name (id: $id)<br />";	
					$p->delete();
				}
				$json = { msg => $msg };
			} else {
				my $nodel = 0;
				my @del;
				foreach my $rev (@revs) {
						warn "rev paste id = " . $rev->get_column("paste_id");
						my $p = $c->model("Paste::paste")->find({id => $rev->get_column("revision_id")});
						warn "paste column data user id: " . $p->get_column("user_id");
						warn "sessh user i : " . $c->session->{__user}->{id};
						if($p->get_column("user_id") != $c->session->{__user}->{id}) {
							$nodel = 1;
							last;
						}
						push @del,$p;
				}
				if($nodel) {
					$json = { error => "You cannot delete a revision if there are revisions under it that you do not own.", errno => 100 }		
				} else {
					foreach my $p (@del) {
						$title = $p->get_column("title");
						my $dd = $p->get_column("id");
						$p->delete();
						warn "Deleted: $title";
						$msg .= "Deleted: $title (id: $dd)<br />";
					}
					$json = { msg => $msg };	
				}
			}
		} elsif(($rev = $self->hasrev($c,$pid)) > 0) {
                        my @revs = $c->model("Paste::revision")->search_literal("paste_id = ?", ($pid));
                        if($c->check_user_roles("admin")) {
                                my @del;
				push @del, $paste;
                                foreach my $rev(@revs) {
                                        my $paste = $c->model("Paste::paste")->find({id => $rev->get_column("revision_id")});
                                        push @del, $paste;
                                }
                                foreach my $p (@del) {
                                        my $uid = $p->get_column("user_id");
                                        my $name = $p->get_column("title");
                                        my $id = $p->get_column("id");
                                        my $time = time;
                                        $c->model("Paste::notification")->create({
                                                user_id => $uid,
                                                message => "Your paste, $name (id: $id), has been deleted.",
                                                created_on => $time
                                        });
                                        warn "Deleted $name";
                                        $msg .= "Deleted: $name (id: $id)<br />";
                                        $p->delete();
                                }
                                $json = { msg => $msg };
                        } else {
                                my $nodel = 0;
                                my @del;
				push @del, $paste;
                                foreach my $rev (@revs) {
                                                warn "rev paste id = " . $rev->get_column("paste_id");
                                                my $p = $c->model("Paste::paste")->find({id => $rev->get_column("revision_id")});
                                                warn "paste column data user id: " . $p->get_column("user_id");
                                                warn "sessh user i : " . $c->session->{__user}->{id};
                                                if($p->get_column("user_id") != $c->session->{__user}->{id}) {
                                                        $nodel = 1;
                                                        last;
                                                }
                                                push @del,$p;
                                }
                                if($nodel) {
                                        $json = { error => "You cannot delete a revision if there are revisions under it that you do not own.", errno => 100 }
                                } else {
                                        foreach my $p (@del) {
                                                $title = $p->get_column("title");
                                                my $dd = $p->get_column("id");
                                                $p->delete();
                                                warn "Deleted: $title";
                                                $msg .= "Deleted: $title (id: $dd)<br />";	
					}
					$json = { msg => $msg };
				}
			}
		}
		elsif($c->check_user_roles("admin") || $oid == $c->session->{__user}->{id}) {
			$paste = $c->model("Paste::paste")->find({id => $pid});
			$paste->delete();
			$json = { msg => "$title has been deleted." };
		} else {
			$json = { error => "You do not have permission to delete this." };
		}
	}
	warn Dumper($json);
	$c->stash(template=>"json/general.json",json=>$json);
}	

sub canDelete : Direct : DirectArgs(1) {
	my ($self, $c) = @_;
	$c->res->content_type("application/json");
	my $opts = $c->req->data->[0];
	my $pid = $opts->{"pid"};
	my $json;
	warn Dumper($c->session->{__user}); 
	if(!defined $pid) {
		warn "no post id";
		$json = { error => "You did not provide a post ID." };
	} else {
		my $paste = $c->model("Paste::paste")->find({id => $pid});
		my $oid = $paste->get_column("user_id");
		my $candel;
		if(!defined $c->session->{__user}) {
			$candel = 0;
		} elsif( $c->check_user_roles("admin") ) {
			$candel = 1;
		} elsif($oid == $c->session->{__user}->{id}) {
			$candel = 1;
		} else {
			$candel = 0;
		}
		$json = { candel => $candel };
	}
	$c->stash(template=>"json/general.json",json=>$json);
}

sub notify : Path("/notify") {
	my ($self, $c) = @_;
	my $json;
	if($c->user_exists) {
		my $time = time-3;
		my $id = $c->session->{__user}->{id};
		my @q = $c->model("Paste::notification")->search_literal("user_id =? AND created_on < ? AND sent_on IS NULL",($id, $time));
		my $len = $#q+1;
		if($len <= 0) {
			$json = { type => "event", name => "message", nothing => 1 };
		} else {
			my $arr = &jarr(\@q);
			warn Dumper($arr);
			my @a = @{$arr};
			my @msgs;
			foreach my $ent(@a) {
				push @msgs, {msg => $ent->{message}, time => $ent->{created_on}};
			}
			$json = {type => "event", name => " message", data => \@msgs};
			foreach my $qq (@q) {
				$qq->update({sent_on => time});
			}	
		}
	} else {
		$json = { type => "event", name => "message", nothing => 1, notloggedin => 1 };
	}
	$c->res->content_type("application/json");
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



=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
