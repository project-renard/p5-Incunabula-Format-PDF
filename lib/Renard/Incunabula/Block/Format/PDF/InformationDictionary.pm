use Renard::Incunabula::Common::Setup;
package Renard::Incunabula::Block::Format::PDF::InformationDictionary;
# ABSTRACT: represents the PDF document information dictionary

use Moo;
use Renard::Incunabula::Common::Types qw(Maybe File InstanceOf Str HashRef ArrayRef);
use Renard::Incunabula::API::MuPDF::mutool;

=attr filename

A C<File> containing the path to a document.

=cut
has filename => (
	is => 'ro',
	isa => File,
	coerce => 1,
);

has _object => (
	is => 'lazy',
	isa => InstanceOf['Renard::Incunabula::API::MuPDF::mutool::ObjectParser'],
	handles => {
	},
);

method _build__object() {
	Renard::Incunabula::API::MuPDF::mutool::get_mutool_get_info_object_parsed( $self->filename );
}

method _get_data( (Str) $key ) {
	my $obj = $self->_object->resolve_key($key);

	return $obj->data if $obj;
}

=attr default_properties

An C<ArrayRef> of the default properties that are expected in the information
dictionary.

=cut
has default_properties => (
	is => 'ro',
	isa => ArrayRef,
	default => sub {
		[qw(
			Title
			Subject
			Author
			Keywords
			Creator
			Producer
			CreationDate
			ModDate
		)]
	},
);

=method Title

=begin :list

= Type

text string

= Description

(Optional; PDF 1.1) The document’s title.

=end :list

=cut
method Title() :ReturnType(Maybe[Str]) {
	$self->_get_data('Title');
}

=method Subject

=begin :list

= Type

text string

= Description

(Optional; PDF 1.1) The subject of the document.

=end :list

=cut
method Subject() :ReturnType(Maybe[Str]) {
	$self->_get_data('Subject');
}

=method Author

=begin :list

= Type

text string

= Description

(Optional) The name of the person who created the document.

=end :list

=cut
method Author() :ReturnType(Maybe[Str]) {
	$self->_get_data('Author');
}

=method Keywords

=begin :list

= Type

text string

= Description

(Optional; PDF 1.1) Keywords associated with the document.

=end :list

=cut
method Keywords() :ReturnType(Maybe[Str]) {
	$self->_get_data('Keywords');
}

=method Creator

=begin :list

= Type

text string

= Description

(Optional) If the document was converted to PDF from another format, the
name of the application (for example, Adobe FrameMaker®) that created the
original document from which it was converted.

=end :list

=cut
method Creator() :ReturnType(Maybe[Str]) {
	$self->_get_data('Creator');
}

=method Producer

=begin :list

= Type

text string

= Description

(Optional) If the document was converted to PDF from another format, the name
of the application (for example, Acrobat Distiller) that converted it to PDF.

=end :list

=cut
method Producer() :ReturnType(Maybe[Str]) {
	$self->_get_data('Producer');
}

=method CreationDate

=begin :list

= Type

date

= Description

(Optional) The date and time the document was created, in human-readable form
(see Section 3.8.3, “Dates”).

=end :list

=cut
method CreationDate() :ReturnType(Maybe[InstanceOf['Renard::Incunabula::API::MuPDF::mutool::DateObject']]) {
	$self->_get_data('CreationDate');
}

=method ModDate

=begin :list

= Type

date

= Description

(Required if PieceInfo is present in the document catalog; otherwise optional;
PDF 1.1) The date and time the document was most recently modified, in
human-readable form (see Section 3.8.3, “Dates”).

=end :list

=cut
method ModDate() :ReturnType(Maybe[InstanceOf['Renard::Incunabula::API::MuPDF::mutool::DateObject']]) {
	$self->_get_data('ModDate');
}

1;
__END__
=head1 DESCRIPTION

Allows for access to the common fields used for the PDF document information
dictionary.

=head1 SEE ALSO

Table 10.2 on pg. 844 of the I<PDF Reference, version 1.7> for more information.

=cut

=begin :header

=begin stopwords

CreationDate ModDate

PieceInfo

FrameMaker FrameMaker®

=end stopwords

=end :header


=cut
