use strict;
use warnings;
use Test::More;
use lib q(lib);
use Data::AsObject dao => { mode => 'strict' };

plan tests => 6;

{
    my $dao = bless { foo => 42, hello => { world => 1 } }, 'Data::AsObject::Hash::Strict';
    my $ref;

    ok($ref = $dao->can('foo'), 'dao can "foo"');
    is(ref $ref, 'CODE', 'can() returns a code ref');
    is($ref->(), 42, 'code ref returns data value');
    ok($ref = $dao->can('hello'), 'dao can "hello"');
    is($dao->$ref->world, 1, 'sub ref holds object');
    is($dao->can('bar'), undef, 'can "bar" returns undef value');
}

