package Chemistry::File::PDB;

$VERSION = '0.05';

use Chemistry::MacroMol;
use Chemistry::Domain;
use Carp;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

=head1 NAME

Chemistry::File::PDB

=head1 SYNOPSIS

    use Chemistry::File::PDB 'pdb_read';

    my $mol = pdb_read("myfile.pdb");

=cut


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

Returns a Chemistry::MacroMol object from the specified PDB file.

=cut

Chemistry::Mol::register_type("pdb",  read => \&pdb_read,
    is => \&is_pdb, );

sub pdb_read {
    my $fname = shift;
    my ($mol) = @_; # a molecule
    my @mols; 
    my ($n_mol, $n_atom);
    my $n_res = 0;
    my $domain;

    open F, $fname or croak "Could not open file $fname";

    $mol ||= Chemistry::MacroMol->new(id => "mol". ++$n_mol);
    while (<F>) {
	if (/^TER/) {
#	    $mol->{name} = $name;
	    #push @mols, $mol;
	    #$mol = new Chemistry::Mol(id => "mol". ++$n_mol);
	    #$n_atom = 0;
	} elsif (/^ATOM/) {
	    my ($symbol, $suff, $res_name, $seq_n, $x, $y, $z) = 
		unpack "x12A2A2x1A3x2A4x4A8A8A8", $_;
	    #print "S:$symbol; N:$name; x:$x; y:$y; z:$z\n";
            $seq_n =~ s/ //g;
            if ($seq_n != $n_res) {
                $domain = Chemistry::Domain->new(parent=>$mol, name=>$res_name,
                    type => $res_name, id => "d".$seq_n);
                $n_res = $seq_n;
                $mol->add_domain($domain);
            }
            my $atom_name = $symbol.$suff;
            $atom_name =~ s/ //g;
	    $domain->new_atom(
		symbol => $symbol, 
		coords => [$x, $y, $z], 
		#id    => "$mol->{id}-$res_name-a".++$n_atom,
		id    => "a".++$n_atom,
                name => $atom_name,
	    );
	}
    }
    close F;

    return $mol;
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

Chemistry::MacroMol

=head1 AUTHOR

Ivan Tubert-Brohman <itub@cpan.org>

=cut

