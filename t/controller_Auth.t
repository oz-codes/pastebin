use strict;
use warnings;
use Test::More;


use Catalyst::Test 'pastebin';
use pastebin::Controller::Auth;

ok( request('/auth')->is_success, 'Request should succeed' );
done_testing();
