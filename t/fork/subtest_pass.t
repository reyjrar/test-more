#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More coordinate_forks => 1;

subtest 'foo' => sub {
    pass 'parent one';
    pass 'parent two';
    my $pid = fork;
    unless ($pid) {
        pass 'child one';
        pass 'child two';
        exit;
    }
    wait;
    pass 'parent three';
};

done_testing;

