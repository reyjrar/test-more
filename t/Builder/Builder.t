#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Builder;
my $Test = Test::Builder->new;

$Test->plan( tests => 8 );

my $default_lvl = $Test->level;
$Test->level(0);

$Test->ok( 1,  'compiled and new()' );
$Test->ok( $default_lvl == 1,      'level()' );
$Test->ok( 1, '' );

$Test->is_eq('foo', 'foo',      'is_eq');
$Test->is_num('23.0', '23',     'is_num');

$Test->is_num( $Test->current_test, 5,  'current_test() get' );

my $test_num = $Test->current_test + 1;
$Test->current_test( $test_num );
print "ok $test_num - current_test() set\n";

$Test->ok( 1, 'counter still good' );
