# NAME

CBOR::Free - Fast CBOR for everyone

# SYNOPSIS

    $cbor = CBOR::Free::encode( $scalar_or_ar_or_hr );

    $thing = CBOR::Free::decode( $cbor )

    my $tagged = CBOR::Free::tag( 1, '2019-01-02T00:01:02Z' );

Also see [CBOR::Free::Decoder](https://metacpan.org/pod/CBOR::Free::Decoder) for an object-oriented interface
to the decoder.

# DESCRIPTION

This library implements [CBOR](https://tools.ietf.org/html/rfc7049)
via XS under a license that permits commercial usage with no “strings
attached”.

# STATUS

This distribution is an experimental effort. Its interface is still
subject to change. If you decide to use CBOR::Free in your project,
please always check the changelog before upgrading.

# FUNCTIONS

## $cbor = encode( $DATA, %OPTS )

Encodes a data structure or non-reference scalar to CBOR.
The encoder recognizes and encodes integers, floats, byte and character
strings, array and hash references, [CBOR::Free::Tagged](https://metacpan.org/pod/CBOR::Free::Tagged) instances,
[Types::Serialiser](https://metacpan.org/pod/Types::Serialiser) booleans, and undef (encoded as null).

The encoder currently does not handle any other blessed references.

%OPTS may be:

- `canonical` - A boolean that makes the function output
CBOR in [canonical form](https://tools.ietf.org/html/rfc7049#section-3.9).

Notes on mapping Perl to CBOR:

- The internal state of a defined Perl scalar (e.g., whether it’s an
integer, float, byte string, or character string) determines its CBOR
encoding.
- [Types::Serialiser](https://metacpan.org/pod/Types::Serialiser) booleans are encoded as CBOR booleans.
Perl undef is encoded as CBOR null. (NB: No Perl value encodes as CBOR
undefined.)
- Instances of [CBOR::Free::Tagged](https://metacpan.org/pod/CBOR::Free::Tagged) are encoded as tagged values.

An error is thrown on excess recursion or an unrecognized object.

## $data = decode( $CBOR )

Decodes a data structure from CBOR. Errors are thrown to indicate
invalid CBOR. A warning is thrown if $CBOR is longer than is needed
for $data.

Notes on mapping CBOR to Perl:

- CBOR text strings become Perl character strings. CBOR binary strings
become Perl byte strings. (This may become configurable later.)

    Note that invalid UTF-8 in a CBOR text string is considered
    invalid input and will thus prompt a thrown exception.

- The only map keys that `decode()` accepts are integers and strings.
An exception is thrown if the decoder finds anything else as a map key.
- CBOR booleans become the corresponding [Types::Serialiser](https://metacpan.org/pod/Types::Serialiser) values.
Both CBOR null and undefined become Perl undef.
- This function does not interpret tags; if you need that, look
at [CBOR::Free::Decoder](https://metacpan.org/pod/CBOR::Free::Decoder). Any tags that this function sees prompt a warning
but are otherwise ignored.

## $obj = tag( $NUMBER, $DATA )

Tags an item for encoding so that its CBOR encoding will preserve the
tag number. (Include $obj, not $DATA, in the data structure that
`encode()` receives.)

# BOOLEANS

`CBOR::Free::true()` and `CBOR::Free::false()` are defined as
convenience aliases for the equivalent [Types::Serialiser](https://metacpan.org/pod/Types::Serialiser) functions.
(Note that there are no equivalent scalar aliases.)

# FRACTIONAL (FLOATING-POINT) NUMBERS

Floating-point numbers are encoded in CBOR as IEEE 754 half-, single-,
or double-precision. If your Perl is compiled to use “long double”
floating-point numbers, you may see rounding errors when converting
to/from CBOR. If that’s a problem for you, append an empty string to
your floating-point numbers, which will cause CBOR::Free to encode
them as strings.

# INTEGER LIMITS

CBOR handles up to 64-bit positive and negative integers. Most Perls
nowadays can handle 64-bit integers, but if yours can’t then you’ll
get an exception whenever trying to parse an integer that can’t be
represented with 32 bits. This means:

- Anything greater than 0xffff\_ffff (4,294,967,295)
- Anything less than -0x8000\_0000 (2,147,483,648)

Note that even 64-bit Perls can’t parse negatives that are less than
\-0x8000\_0000\_0000\_0000 (-9,223,372,036,854,775,808); these also prompt an
exception since Perl can’t handle them. (It would be possible to load
[Math::BigInt](https://metacpan.org/pod/Math::BigInt) to handle these; if that’s desirable for you,
file a feature request.)

# ERROR HANDLING

Most errors are represented via instances of subclasses of
[CBOR::Free::X](https://metacpan.org/pod/CBOR::Free::X), which subclasses [X::Tiny::Base](https://metacpan.org/pod/X::Tiny::Base).

# SPEED

CBOR::Free is pretty snappy. I find that it keeps pace with or
surpasses [CBOR::XS](https://metacpan.org/pod/CBOR::XS), [Cpanel::JSON::XS](https://metacpan.org/pod/Cpanel::JSON::XS), [JSON::XS](https://metacpan.org/pod/JSON::XS), [Sereal](https://metacpan.org/pod/Sereal),
and [Data::MessagePack](https://metacpan.org/pod/Data::MessagePack).

It’s also quite light. Its only “heavy” dependency is
[Types::Serialiser](https://metacpan.org/pod/Types::Serialiser), which is only loaded when you actually need it.
This keeps memory usage low for when, e.g., you’re using CBOR for
IPC between Perl processes and have no need for true booleans.

# AUTHOR

[Gasper Software Consulting](http://gaspersoftware.com) (FELIPE)

# LICENSE

This code is licensed under the same license as Perl itself.

# SEE ALSO

[CBOR::PP](https://metacpan.org/pod/CBOR::PP) is a pure-Perl CBOR library.

[CBOR::XS](https://metacpan.org/pod/CBOR::XS) is an older CBOR module on CPAN. It’s got more bells and
whistles, so check it out if CBOR::Free lacks a feature you’d like.
Note that [its maintainer has abandoned support for Perl versions from 5.22
onward](http://blog.schmorp.de/2015-06-06-stableperl-faq.html), though,
and its GPL license limits its usefulness in
commercial [perlcc](https://metacpan.org/pod/distribution/B-C/script/perlcc.PL)
applications.
