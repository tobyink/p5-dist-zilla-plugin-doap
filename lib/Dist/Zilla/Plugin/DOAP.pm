use strict;
use warnings;

package Dist::Zilla::Plugin::DOAP;
# ABSTRACT: create a doap.xml file for your project

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001';

use Moose;
with qw(
	Dist::Zilla::Role::FileGatherer
);

use namespace::autoclean;
use CPAN::Changes;
use CPAN::Meta;
use Dist::Zilla::File::InMemory;
use RDF::DOAP::Lite;

has xml_filename => (
	is      => 'ro',
	isa     => 'Maybe[Str]',
	default => 'doap.xml',
);

has ttl_filename => (
	is      => 'ro',
	isa     => 'Maybe[Str]',
);

sub gather_files
{
	my $self  = shift;
	
	my $zilla = $self->zilla;
	my $doap  = 'RDF::DOAP::Lite'->new(
		meta => 'CPAN::Meta'->new( {%{$zilla->distmeta}} ),
		((-f 'Changes')
			? (changes => 'CPAN::Changes'->load('Changes'))
			: ()),
	);
	
	if ($self->xml_filename)
	{
		my $data;
		open my $fh, '>', \$data;
		$doap->doap_xml($fh);
		close $fh;
		
		$self->add_file('Dist::Zilla::File::InMemory'->new(
			name    => $self->xml_filename,
			content => $data,
		));
	}	

	if ($self->ttl_filename)
	{
		my $data;
		open my $fh, '>', \$data;
		$doap->doap_ttl($fh);
		close $fh;
		
		$self->add_file('Dist::Zilla::File::InMemory'->new(
			name    => $self->ttl_filename,
			content => $data,
		));
	}	
}
 
__PACKAGE__->meta->make_immutable;

1;
