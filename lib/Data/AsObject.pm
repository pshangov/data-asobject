package Data::AsObject;

use warnings;
use strict;
use Carp;
use Scalar::Util qw(reftype blessed);
use Data::AsObject::Hash;
use Data::AsObject::Array;



our $__check_type = sub {
	my $data = shift;
	return unless $data;

	my $type = reftype($data);

	if (defined $type) {
		if ( $type eq "ARRAY" && ( !blessed($data) || ref($data) eq "Data::AsObject::Array" ) ) {
			return "ARRAY";
		} elsif ( $type eq "HASH" && ( !blessed($data) || ref($data) eq "Data::AsObject::Hash" ) ) {
			return "HASH";
		} else {
			return "";
		}
	} else {
		return "";
	}
};

sub _build_dao 
{
	my ($class, $sub, $arg) = @_;
	#use Data::Dumper qw(Dumper);
	#warn Dumper \@_;
	$arg ||= {};
	my ($array_class, $hash_class);
	my $mode = $arg->{mode};

	if ($mode)
	{
		if ($mode eq 'strict')
		{
			$array_class = 'Data::AsObject::Array::Strict';
			$hash_class = 'Data::AsObject::Hash::Strict';
		}
		elsif ($mode eq 'loose')
		{
			$array_class = 'Data::AsObject::Array::Loose';
			$hash_class = 'Data::AsObject::Hash::Loose';
		}
		elsif ($mode eq 'silent')
		{
			$array_class = 'Data::AsObject::Array::Silent';
			$hash_class = 'Data::AsObject::Hash::Silent';
		}
		else
		{
			croak "Unknown mode '$mode' for dao construction";
		}
	}
	else
	{
		$array_class = 'Data::AsObject::Array::Strict';
		$hash_class = 'Data::AsObject::Hash::Strict';
	}
	

	return sub 
	{
		my @args = @_;
		my @result;

		foreach my $data (@args) {
		
			my $type = reftype($data);
			my $dao;
		
			if ($type eq "ARRAY") {
				$dao = bless $data, "Data::AsObject::Array";
			} elsif ($type eq "HASH") {
				$dao = bless $data, "Data::AsObject::Hash";
			} else {
				carp "Invalid argument to dao: must be hashref or arrayref!";
				$dao = undef;
			}
			push @result, $dao;
		}

		return wantarray ? @result : $result[0];
	}
}

use Sub::Exporter -setup => { exports => [ dao => \'_build_dao' ] };

1; 

=head1 NAME

Data::AsObject - Easy OO access to complex perl data structures

=head1 SYNOPSIS

	use Data::AsObject qw(dao);
	
	my $book = dao { 
		name      => "Programming Perl",
		authors   => ["Larry Wall", "Tom Christiansen", "Jon Orwant"],
		
	};
    
	print $book->name              # prints "Programming Perl"
	print $book->authors(0)        # prints "Larry Wall"
	my $array_ref = $book->authors # $array_ref is ["Larry Wall", "Tom Christiansen", "Jon Orwant"]
	my @array = $book->authors     # @array is ("Larry Wall", "Tom Christiansen", "Jon Orwant")
	$book->{publisher} = "O'Reilly";
	print $book->publisher         # prints "O'Reilly"

=head1 DESCRIPTION

C<Data::AsObject> provides easy object-oriented access to complex and arbitrarily nested perl data structures. It is particulary suitable for working with hash-based representation of XML data, as generated by modules like L<XML::Complie> or L<XML::TreePP>.

=head1 WARNING

Version 0.06 of C<Data::AsObject> broke backwards compatibility with two changes that may break existing scrpts. 

=over 

=item * 

Automatic dereferencing in list context is no longer provided. Use L<Ref::List::AsObject> to achieve this result.

=item * 

An attempt to access an unexisting hash key or array item now dies rather than simply produce a warning. Use an exception handling mechanism to check if the data you want to access is actually there.

=back

=head1 BENEFITS

These are some of the reasons why you may want to use C<Data::AsObject>:

=over 

=item Object-oriented syntax

The object-oriented syntax may sometimes be more appropriate than the traditional hashref and arrayref syntax.

=item Protection from misspelled hash key names

Since C<Data::AsObject> does not preform any autovivification, it protects you from misspelling a hash key when accessing its value (but see also L<Hash::Util> for more robust ways to do that).

=item Easy access to hash keys with non-standard symbols

If your hashes contain a lot of keys with dashes or colons, as is often the case with keys representing xml element names, C<Data::AsObject> can autmatically access such keys by substituting underscores for the non-standard symbols.

=item Easy dereferencing of arrayref

If you have a lot of arrayrefs in your data structure that often need to be traversed, e.g. with C<grep>, C<map> or C<foreach>, C<Data::AsObject> works in conjunction with L<Ref::List::AsObject> to make automatic dereferencing very convenient.

=back

=head1 FUNCTIONS

=head2 dao

Takes as input one or more hash or array references, and returns one or more objects (C<Data::AsObject::Hash> or C<Data::AsObject::Array> respectively) that can be used to access the data structures via an object oriented interface. Exported by default.

=head1 USAGE

=head2 Working with hashes

To access hash elements by key, use the hash key as method name:

	my $data = dao { three => { two => { one => "kaboom" } } };
	print $data->three->two->one; # kaboom

If a hash key contains one or more colons or dashes, you can access its value by substituting underscores for the colons or dashes (the underlying hash key name is not modified).

	my $data = dao { 
		'xml:lang'     => "EN", 
		'element-name' => "some name",
	};

	print $data->xml_lang     # "EN"
	print $data->element_name # "some name"

=head2 Working with arrays

To access array items pass the item index as an argument to the hash that contains the array:

	my $data = dao {
		uk => ["one", "two", "three", "four"],
		spain => [ 
			{ name => 'spanish', numbers => ["uno", "dos", "tres", "cuatro"] },
			{ name => 'catalan', numbers => ["un", "dos", "tres", "quatre"] },
		];
	};

	print $data->en(1) # two
	print $data->spain(0)->numbers(3); # cuatro

Array of array structures are a little bit clumsier to work with. You will need to use the C<get> method of C<Data::AsObject::Array> and pass it the index of the item you want to access:

	my $data = dao [
		["one", "two", "three", "four"]
		["uno", "dos", "tres", "cuatro"],
		["un", "dos", "tres", "quatre"],
	];

	print $data->get(2)->get(0); # un

=head2 Integration with L<Ref::List::AsObject>

C<Data::AsObject> can work with L<Ref::List::AsObject> (from the L<Ref::List> distribution) to allow easy dereferencing of arrayrefs and hashrefs in list context. For example:

	use Ref::List::AsObject qw(list);
	
	my $data = dao {
		spain => [ 
			{ name => 'spanish', numbers => ["uno", "dos", "tres", "cuatro"] },
			{ name => 'catalan', numbers => ["un", "dos", "tres", "quatre"] },
		];
	};

	foreach my $n ( list $data->spain ) {
		print $n->name . " ";
	} # spanish catalan

=head2 Modifying data

C<Data::AsObject> only provides accessor functions. To modify data, access the respective hash or array element directly:

	my $data = dao {};
	$data->{one} = "uno";
	print $data->one # uno

Note that the accessor methods return references to the underlying data structure rather than clones:

	my $data = dao {};
	my $copy = $data;

	$data->{one} = "uno";
	print $copy->one # uno

=head2 Autovivification

No autovivification is performed. An attempt to access a hash or array element that does not exist will produce a fatal error. Use an exception handling mechanism such as L<Try::Tiny>.

	use Try::Tiny;

	my $data = dao {
		uk      => ["one", "two", "three", "four"],
		spain   => ["uno", "dos", "tres", "cuatro"],
		germany => ["eins", "zwei", "drei", "vier"].
	};

	try {
		my $numbers = $data->bulgaria;
	} catch {
		warn "No info about Bulgaria!";
	};

=head2 C<Data::AsObject::Hash> and special methods

If C<$data> isa C<Data::AsObject::Hash>:

=over

=item can

Attempts to call C<$data-E<gt>can("some_method_name")> will always return C<undef>, regardless of whether a C<$data-E<gt>{"some_method_name"}> hash key exists or not.

=item VERSION

Calling C<$data-E<gt>VERSION> will attempt to return the value of a hash element with a key "VERSION". Use C<Data::AsObject-E<gt>VERSION> instead.

=item others special methods

All other special methods and functions (C<isa>, C<ref>, C<DESTROY>) should behave as expected.

=back

=head1 AUTHOR

Petar Shangov, C<< <pshangov at yahoo dot com> >>

=head1 BUGS

This is still considered alpha-stage software, so problems are expected. Please report any bugs or feature requests to C<bug-data-object at rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-Object>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Data::Object

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-Object>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Data-Object>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Data-Object>

=item * Search CPAN

L<http://search.cpan.org/dist/Data-Object/>

=back


=head1 SEE ALSO

L<Hash::AsObject>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Petar Shangov, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut


