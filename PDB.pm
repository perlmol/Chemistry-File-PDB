package Chemistry::File::PDB;

use Chemistry::Mol;
use Carp;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

=head1 NAME

Chemistry::File::PDB

=head1 SYNOPSIS

    use Chemistry::File::PDB 'pdb_read';

    my $mol = pdb_read("myfile.pdb");

=cut

$VERSION = '0.1';

require Exporter;

@ISA = qw(Exporter);


@EXPORT = qw(  );

@EXPORT_OK = qw( pdb_read );

%EXPORT_TAGS = (
   all  => [@EXPORT, @EXPORT_OK]
);

=head1 DESCRIPTION

PDB file reader. Currently only uses ATOM records.

This module automatically registers the 'pdb' format with Chemistry::Mol,
so that PDB files may be identified and read by Chemistry::Mol::read_mol().

=head1 FUNCTIONS

=over 4

=item pdb_read($fname)

Returns a list of Mol objects from the specified PDB file.

=cut

Chemistry::Mol::register_type("pdb",  read => \&pdb_read,
    is => \&is_pdb, );

sub pdb_read($) {
    my $fname = shift;
    my $mol; # a molecule
    my @mols; 
    my $n_mol;
    my $n_atom;
    my ($symbol, $name, $x, $y, $z);

    open F, $fname or croak "Could not open file $fname";

    $mol = new Chemistry::Mol(id => "mol". ++$n_mol);
    while (<F>) {
	if (/^TER/) {
	    $mol->{name} = $name;
	    push @mols, $mol;
	    $mol = new Chemistry::Mol(id => "mol". ++$n_mol);
	    $n_atom = 0;
	} elsif (/^ATOM/) {
	    ($symbol, $name, $x, $y, $z) = 
		unpack "x12A2x3A3x10A8A8A8", $_;
	    #print "S:$symbol; N:$name; x:$x; y:$y; z:$z\n";
	    $mol->add_atom(new Chemistry::Atom(
		symbol => $symbol, 
		coords => [$x, $y, $z], 
		id    => "$mol->{id}-$name-a".++$n_atom)
	    );
	}
    }
    close F;

    return @mols;
}

=item is_pdb($fname)

Returns true if the specified file is a PDB file.

=cut

sub is_pdb {
    my $fname = shift;
    
    return 1 if $fname =~ /\.pdb$/i;

    open F, $fname or croak "Could not open file $fname";
    
    while (<F>){
	if (/^ATOM/) {
	    close F;
	    return 1;
	}
    }

    return 0;
}

1;


=head1 SEE ALSO

Chemistry::Mol

=head1 AUTHOR

Ivan Tubert-Brohman <ivan@tubert.org>

=head1 VERSION

$Id$

=cut

