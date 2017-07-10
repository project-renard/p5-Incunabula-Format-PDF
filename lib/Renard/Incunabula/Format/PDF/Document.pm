use Renard::Incunabula::Common::Setup;
package Renard::Incunabula::Format::PDF::Document;
# ABSTRACT: document that represents a PDF file

use Moo;
use Renard::Incunabula::MuPDF::mutool;
use Renard::Incunabula::Format::PDF::Page;
use Renard::Incunabula::Outline;
use Renard::Incunabula::Common::Types qw(PageNumber ZoomLevel);

use Math::Trig;
use Math::Polygon;

use Function::Parameters;

extends qw(Renard::Incunabula::Document);

has _raw_bounds => (
	is => 'lazy', # _build_raw_bounds
);

=begin comment

=method _build_last_page_number

Retrieves the last page number of the PDF. Currently implemented through
C<mutool>.

=end comment

=cut
method _build_last_page_number() :ReturnType(PageNumber) {
	my $info = Renard::Incunabula::MuPDF::mutool::get_mutool_page_info_xml(
		$self->filename
	);

	return scalar @{ $info->{page} };
}

=method get_rendered_page

  method get_rendered_page( (PageNumber) :$page_number )

See L<Renard::Incunabula::Document::Role::Renderable>.

=cut
method get_rendered_page( (PageNumber) :$page_number, (ZoomLevel) :$zoom_level = 1.0 ) {
	return Renard::Incunabula::Format::PDF::Page->new(
		document => $self,
		page_number => $page_number,
		zoom_level => $zoom_level,
	);
}

method _build_outline() {
	my $outline_data = Renard::Incunabula::MuPDF::mutool::get_mutool_outline_simple(
		$self->filename
	);

	return Renard::Incunabula::Outline->new( items => $outline_data );
}

method _build__raw_bounds() {
	my $info = Renard::Incunabula::MuPDF::mutool::get_mutool_page_info_xml(
		$self->filename
	);
}

method _build_identity_bounds() {
	my $compute_rotate_dim = sub {
		my ($info) = @_;
		my $theta_deg = $info->{rotate} // 0;
		my $theta_rad = $theta_deg * pi / 180;

		my ($x, $y) = ($info->{x}, $info->{y});
		my $poly = Math::Polygon->new(
			points => [
				[0, 0],
				[$x, 0],
				[$x, $y],
				[0, $y],
			],
		);

		my $rotated_poly = $poly->rotate(
			degrees => $theta_deg,
			center => [ $x/2, $y/2 ],
		);

		my ($xmin, $ymin, $xmax, $ymax) = $rotated_poly->bbox;


		return { w => $xmax - $xmin, h => $ymax - $ymin };
	};

	my $bounds = $self->_raw_bounds;
	my @page_xy = map {
		my $p = {
			x => $_->{MediaBox}{r},
			y => $_->{MediaBox}{t},
			rotate => $_->{Rotate}{v} // 0,
			pageno => $_->{pagenum},
		};
		if( exists $p->{rotate} ) {
			$p->{dims} = $compute_rotate_dim->( $p );
		}

		$p;
	} @{ $bounds->{page} };

	return \@page_xy;
}

with qw(
	Renard::Incunabula::Document::Role::FromFile
	Renard::Incunabula::Document::Role::Pageable
	Renard::Incunabula::Document::Role::Renderable
	Renard::Incunabula::Document::Role::Cacheable
	Renard::Incunabula::Document::Role::Outlineable
	Renard::Incunabula::Document::Role::Boundable
);

1;
