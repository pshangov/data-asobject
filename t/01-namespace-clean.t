use strict;
use warnings;
use Test::More;
use lib q(lib);
use Data::AsObject dao => { mode => 'strict' };

plan tests => 2;

{
    my $dao = bless { foo => [1,2,3] }, 'Data::AsObject::Hash::Strict';
    is(eval { $dao->croak('bar') }, undef, 'croak does not exist in config');
    like($@, qr{attempting to access}i, 'croak is cleaned out of namespace');
}

