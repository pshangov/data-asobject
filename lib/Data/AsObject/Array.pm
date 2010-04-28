package Data::AsObject::Array;

use strict;
use warnings;
use Carp;
use Scalar::Util qw(reftype blessed);
use Data::AsObject;


sub get {
	my $self = shift;
	my $index = shift;

	# user wants to fetch a value
	if (defined $index) {
		# the value exists
		if ( exists $self->[$index] ) {
			my $data = $self->[$index];
			
			if ( $Data::AsObject::__check_type->($data) eq "ARRAY" ) {
				return bless $data, "Data::AsObject::Array";
			} elsif ( $Data::AsObject::__check_type->($data) eq "HASH" ) {
				return bless $data, "Data::AsObject::Hash";
			} else {
				return $data;
			}
		# the value does not exist
		} else {
			carp "Attempting to access non-existing array index [$index]!";
			return;
		}
	} else {
		carp "Array accessor get requires index argument!"
	}
}

1;
