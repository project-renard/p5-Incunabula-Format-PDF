use Renard::Incunabula::Common::Setup;
package Renard::Incunabula::Format::PDF::Page;
# ABSTRACT: Page from a PDF document

use Moo;
use MooX::HandlesVia;
use Cairo;
use POSIX qw(ceil);

use Renard::Incunabula::Common::Types qw(Str InstanceOf HashRef);
use Renard::Incunabula::Document::Types qw(ZoomLevel PageNumber);

=attr document

  InstanceOf['Renard::Incunabula::Format::PDF::Document']

The document that created this page.

=cut
has document => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Incunabula::Format::PDF::Document'],
);

=attr page_number

  PageNumber

The page number that this page represents.

=cut
has page_number => ( is => 'ro', required => 1, isa => PageNumber, );

=attr zoom_level

  ZoomLevel


The zoom level for this page.

=cut
has zoom_level => ( is => 'ro', required => 1, isa => ZoomLevel, );

has png_data => (
	is => 'lazy', # _build_png_data
	isa => Str,
);

method _build_png_data() {
	my $png_data = Renard::Incunabula::MuPDF::mutool::get_mutool_pdf_page_as_png(
		$self->document->filename, $self->page_number, $self->zoom_level
	);
}


=attr height

The height of the page at with the current parameters.

=attr width

The width of the page at with the current parameters.

=cut
has _size => (
	is => 'lazy',
	isa => HashRef,
	handles_via => 'Hash',
	handles => {
		width => ['get', 'width'],
		height => ['get', 'height'],
	},
);

method _build__size() {
	my $page_identity = $self->document
		->identity_bounds
		->[ $self->page_number - 1 ];

	# multiply to account for zoom-level
	my $w = ceil($page_identity->{dims}{w} * $self->zoom_level);
	my $h = ceil($page_identity->{dims}{h} * $self->zoom_level);

	{ width => $w, height => $h };
}


with qw(
	Renard::Incunabula::Page::Role::CairoRenderableFromPNG
);

1;
