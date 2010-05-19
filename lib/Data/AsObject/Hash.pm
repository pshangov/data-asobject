package Data::AsObject::Hash;

use strict;
use warnings;
use Carp;
use Data::AsObject ();
use namespace::clean -except => [qw/AUTOLOAD/];

our $AUTOLOAD;

sub can {
    if(@_ != 2) {
        local $AUTOLOAD = ref($_[0]) .'::can';
        return $_[0]->AUTOLOAD(@_);
    }

    my($self, $key) = @_;
    return unless( exists $self->{$key} );
    return sub { _new_data($self, $key) };
}

sub AUTOLOAD {
	my $self = shift;
	my $index = shift;
        my $data;

	my $key = $AUTOLOAD;
	$key =~ s/.*:://;
	undef $AUTOLOAD;

	if ($key eq "can" && defined $index && $index != /\d+/) {
		return undef;
	}

	if ($key eq "isa" && defined $index && $index != /\d+/) {
		$index eq ref($self) or 
		$index eq "Data::AsObject::Hash" or 
		$index eq "UNIVERSAL"
			? return 1 
			: return 0;
	}

        return _new_data($self, $key, $index);
}

sub _new_data {
	my $self = shift;
	my $key = shift;
	my $index = shift;
	my $data = exists $self->{$key} ? $self->{$key} : _data_by_guess($self, $key);
	my $mode = ref($self) =~ /^.*::(\w+)$/ ? $1 : '';

	unless ( $data ) {
	    return;
	}

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
		bless $data, "Data::AsObject::Array::$mode";
	} elsif ( $Data::AsObject::__check_type->($data) eq "HASH" ) {
		bless $data, "Data::AsObject::Hash::$mode";
	}

	return $data;
}

sub _data_by_guess {
	my $self = shift;
	my $key_regex = shift;
	my $has_colon_or_dash = $key_regex =~ s/_/[-:]/g;
	my @matches = grep(/$key_regex/, keys %$self) if $has_colon_or_dash;

	if ( @matches == 1 ) {
		return $self->{$matches[0]};
	} elsif ( @matches > 1 ) {
		carp "Attempt to disambiguate hash key $key_regex returns multiple matches!";
	}

	return;
}


package Data::AsObject::Hash::Strict;
use base 'Data::AsObject::Hash';

package Data::AsObject::Hash::Loose;
use base 'Data::AsObject::Hash';

package Data::AsObject::Hash::Silent;
use base 'Data::AsObject::Hash';

1;
