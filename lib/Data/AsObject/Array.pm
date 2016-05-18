package Data::AsObject::Array;

# ABSTRACT: Base class for Data::AsObject arrayrefs

use strict;
use warnings;

use Carp qw(carp croak);
use Data::AsObject qw();
use namespace::clean -except => [qw/get/];


# Define what happens if objects of this class are used as subroutine references, 
# i.e. if called like this: $obj->(@args).  We define:
#
#         $obj->(@args) <=> $obj->get(@args)
#
use overload '&{}' => sub {
                            my $self = shift;
                            return sub {
                                return $self->get(@_);
                            };
                          },
             # activate default behaviour for all other contexts
             # if you do not, things like if (! $obj) will throw
             # strange errors: Operation "bool": no method found, ...
             'fallback' => 1, 
;


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

sub list
{
    my $self = shift;
    croak "List does not accept arguments" if @_;

    my $mode;
    $mode = 'strict' if $self->isa('Data::AsObject::Array::Strict');
    $mode = 'loose'  if $self->isa('Data::AsObject::Array::Loose');
    $mode = 'silent' if $self->isa('Data::AsObject::Array::Silent');
    carp "Unknown class used as Data::AsObject::Array" unless $mode;

    my @array;
    foreach  my $value (@$self)
    {
        $Data::AsObject::__check_type->($value)
            ? push @array, Data::AsObject::__bless_dao($value, $mode)
            : push @array, $value;
    }
    return @array;
}

package Data::AsObject::Array::Strict;
use base 'Data::AsObject::Array';

package Data::AsObject::Array::Loose;
use base 'Data::AsObject::Array';

package Data::AsObject::Array::Silent;
use base 'Data::AsObject::Array';

1;

=head1 NAME

Data::AsObject::Array - Base class for Data::AsObject arrays

=head1 SYNOPSIS

See L<Data::AsObject> for more information.
