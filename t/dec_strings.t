#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use_ok('CBOR::Free');

my @tests;

for my $n ( 0, 1, 23 ) {
    push @tests, [ $n, ('a' x $n), pack('Ca*', 64 + $n, ('a' x $n)) ];
}

for my $n ( 24, 255 ) {
    push @tests, [ $n, ('a' x $n), pack('CCa*', 88, $n, ('a' x $n)) ];
}

for my $n ( 256, 65535 ) {
    push @tests, [ $n, ('a' x $n), pack('Cna*', 89, $n, ('a' x $n)) ];
}

for my $n ( 65536, 100000 ) {
    push @tests, [ $n, ('a' x $n), pack('CNa*', 90, $n, ('a' x $n)) ];
}

for my $t (@tests) {
    my ($size, $decoded, $cbor) = @$t;

    is(
        CBOR::Free::decode($cbor),
        $decoded,
        "binary size: $size",
    );

    my $utf8cbor = $cbor;
    substr( $utf8cbor, 0, 1 ) ^= "\x40";
    substr( $utf8cbor, 0, 1 ) |= "\x60";

    is(
        CBOR::Free::decode($utf8cbor),
        $decoded,
        "UTF-8 size: $size",
    );
}

done_testing;

