#!/usr/bin/perl -w

# There was a bug with like() involving a qr// not failing properly.
# This tests against that.

use strict;
use warnings;

use lib 't/lib';

# Can't use Test.pm, that's a 5.005 thing.
package My::Test;

# This has to be a require or else the END block below runs before
# Test::Builder's own and the ending diagnostics don't come out right.
require Test::Builder;
my $TB = Test::Builder->create;
$TB->plan(tests => 4);


require Test::Simple::Catch;
my($out, $err) = Test::Simple::Catch::caught();
local $ENV{HARNESS_ACTIVE} = 0;


package main;

require Test::More;
Test::More->import(tests => 1);

{
    eval q{ like( "foo", qr/that/, 'is foo like that' ); };

    $TB->is_eq($out->read, <<OUT, 'failing output');
TAP version 13
1..1
not ok 1 - is foo like that
OUT

    # Accept both old and new-style stringification
    my $modifiers = (qr/foobar/ =~ /\Q(?^/) ? '\\^' : '-xism';

    my $err_re = <<ERR;
#   Failed test 'is foo like that'
#   at .* line 1\.
#                   'foo'
#     doesn't match '\\(\\?$modifiers:that\\)'
ERR

    $TB->like($err->read, qr/^$err_re$/, 'failing errors');
}

{
# line 62
    like("foo", "not a regex");
    $TB->is_eq($out->read, <<OUT);
not ok 2
OUT

    $TB->is_eq($err->read, <<OUT);
#   Failed test at $0 line 62.
#     'not a regex' doesn't look much like a regex to me.
OUT

}

END {
    # Test::More thinks it failed.  Override that.
    exit $TB->history->test_was_successful ? 0 : 1;
}
