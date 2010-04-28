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
				bless $data, "Data::AsObject::Array";
				return wantarray ? $data->all : $data;
			} elsif ( $Data::AsObject::__check_type->($data) eq "HASH" ) {
				return wantarray ? %{$data} : bless $data, "Data::AsObject::Hash";
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

sub all {
	my $self = shift;
	
	return map { $Data::AsObject::__check_type->($_) ? Data::AsObject::dao($_) : $_} @{$self};
}

1;
