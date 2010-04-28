#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Data::AsObject' );
}

diag( "Testing Data::AsObject $Data::AsObject::VERSION, Perl $], $^X" );
