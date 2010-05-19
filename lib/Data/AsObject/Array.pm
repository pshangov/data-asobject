package Data::AsObject::Array;

use strict;
use warnings;

use Carp qw(carp croak);
use Data::AsObject qw();
use namespace::clean -except => [qw/get/];


sub get {
	my $self = shift;
	my $index = shift;

	ref($self) =~ /^.*::(\w+)$/;
	my $mode = $1;

	# user wants to fetch a value
	if (defined $index) {
		# the value exists
		if ( exists $self->[$index] ) {
			my $data = $self->[$index];
			
			if ( $Data::AsObject::__check_type->($data) eq "ARRAY" ) {
				return bless $data, "Data::AsObject::Array::$mode";
			} elsif ( $Data::AsObject::__check_type->($data) eq "HASH" ) {
				return bless $data, "Data::AsObject::Hash::$mode";
			} else {
				return $data;
			}
		# the value does not exist
		} else {
			my $msg = "Attempting to access non-existing array index [$index]!";
			
			if ($mode eq 'Strict')
			{
				carp $msg;
			}
			elsif ($mode eq 'Loose')
			{
				croak $msg;
			}

			return;
		}
	} else {
		carp "Array accessor get requires index argument!"
	}
}

package Data::AsObject::Array::Strict;
use base 'Data::AsObject::Array';

package Data::AsObject::Array::Loose;
use base 'Data::AsObject::Array';

package Data::AsObject::Array::Silent;
use base 'Data::AsObject::Array';

1;
