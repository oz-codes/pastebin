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
		$c->model("Paste::user")->find({id=>$uid})->update({last_paste => $id});
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
		if($c->user_exists) {
			$c->model("Paste::user")->find({id=>$uid})->update({last_paste => $id});
		}
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
        } else {
                my $language = $kate->syntaxes->{$lang};
                chomp($language);
                my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
                my $datetime = sprintf "%4d-%02d-%02d %02d:%02d:%02d\n",$year+1900,$mon+1,$mday,$hour,$min,$sec;
                my $db = $c->model("Paste::paste");
		my $version = c->model("Paste::revision")->search({paste_id => $oldId});
		$version = defined $version ? $version+1 : 1;
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
                if($c->user_exists) {
                        $c->model("Paste::user")->find({id=>$uid})->update({last_paste => $id});
                }
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
		if($#row<0) {
			$json = { error => "I couldn't find that book.", errno => 8 };
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
		}
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
