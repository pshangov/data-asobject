#!perl -T

use strict;
use warnings;

use lib q(lib);

use Test::More ;
use Test::Exception;
use Test::Warn;

use Data::AsObject qw(dao);

plan ();

my $data = {
    blah => [1,2,3],
    bing => [
        { town => 'sliven', 
          matrix => [
              [ 11, 12 ],
              [ 21, 22 ],
          ] 
        },
    ],
    'xml:thingy' => 2,
    'meaning-of-life' => 42,
};

#-- construct from hashref
my $dao = dao $data;
isa_ok($dao, "Data::AsObject::Hash");


my $idx = 2;
my $expected = 3;

#-- check the old interface for array access
ok( $dao->blah($idx) == $expected, "array access via blah($idx) works" ); 
ok( $dao->blah->get($idx) == $expected, "array access via blah->get($idx) works" ); 


#-- check the new interface for array access
ok( $dao->blah->($idx) == $expected, "array access via blah->($idx) works" ); 

$expected = 12;
ok( $dao->bing->(0)->matrix->(0)->(1)    == $expected, "array access bing->(0)->matrix->(0)->(1) works" );
ok( $dao->bing(0)->matrix->(0)->(1)      == $expected, "array access bing(0)->matrix->(0)->(1) works" );
ok( $dao->bing->get(0)->matrix->(0)->(1) == $expected, "array access bing->get(0)->matrix->(0)->(1) works" );

# combining old and new interface 
ok( $dao->bing->(0)->matrix->(0)(1)      == $expected, "array access bing->(0)->matrix->(0)(1) works" );
ok( $dao->bing->(0)->matrix(0)->(1)      == $expected, "array access bing->(0)->matrix(0)->(1) works" );
ok( $dao->bing->(0)->matrix->(0)->get(1) == $expected, "array access bing->(0)->matrix->(0)->get(1) works" );

# Syntax error:
# ok( $dao->bing->(0)->matrix->get(0)(1)   == $expected, "array access bing->(0)->matrix->get(0)(1) works" );
# ok( $dao->bing->(0)->matrix(0)(1)   == $expected, "array access bing->(0)->matrix->(0)(1) works" );

#-- check if default contexts for array objects still work
my $obj = $dao->blah;

ok( "$obj" =~ /^Data::AsObject::Array::Strict=ARRAY/, "string context of array object works" );
ok(  !! $obj,  "boolean context of array object works" );

done_testing();
