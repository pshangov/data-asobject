package Data::AsObject::Hash;

use strict;
use warnings;
use Carp;
use Scalar::Util qw(reftype blessed);
use Data::AsObject ();
use Data::AsObject::Array ();

our $AUTOLOAD;

sub AUTOLOAD {
	my $self = shift;
	my $index = shift;

	my $key = $AUTOLOAD;
	$key =~ s/.*:://;
	undef $AUTOLOAD;

	if ($key eq "can" && defined $index && $index != /\d+/) {
		return undef;
	}

	if ($key eq "isa" && defined $index && $index != /\d+/) {
		$index eq "Data::AsObject::Hash" or $index eq "UNIVERSAL" 
			? return 1 
			: return 0;
	}
	
	my $data;

	if ( exists $self->{$key} ) {
		$data = $self->{$key};
	} else {
		my $key_regex = $key;
		my $has_colon_or_dash = $key_regex =~ s/_/[-:]/g;
		my @matches = grep(/$key_regex/, keys %$self) if $has_colon_or_dash;

		if (@matches == 1) {
			$data = $self->{$matches[0]};
		} elsif (@matches > 1) {
			carp "Attempt to disambiguate hash key $key returns multiple matches!";
			return;
		} else {
			carp "Attempting to access non-existing hash key $key!" unless $key eq "DESTROY";
			return;
		}
	}

	if ( $data ) {
		if (
			   defined $index
			&& $index =~ /\d+/
			&& $Data::AsObject::__check_type->($data) eq "ARRAY"
			&& exists $data->[$index]
		)
		{
			$data = $data->[$index];
		}
			
		if ( $Data::AsObject::__check_type->($data) eq "ARRAY" ) {
			bless $data, "Data::AsObject::Array";
			return wantarray ? $data->all : $data;
		} elsif ( $Data::AsObject::__check_type->($data) eq "HASH" ) {
			return wantarray ? %{$data} : bless $data, "Data::AsObject::Hash";
		} else {
			return $data;
		}
	}
}

1;
