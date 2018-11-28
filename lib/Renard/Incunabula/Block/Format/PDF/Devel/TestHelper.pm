use Renard::Incunabula::Common::Setup;
package Renard::Incunabula::Block::Format::PDF::Devel::TestHelper;
# ABSTRACT: A test helper with functions useful for testing PDF documents

use Renard::Incunabula::Common::Types qw(InstanceOf);

use Renard::Incunabula::Devel::TestHelper;
use Renard::Incunabula::Block::Format::PDF::Document;

=classmethod pdf_reference_document_path

Returns the path to C<pdf_reference_1-7.pdf> in the test data directory.

=cut
classmethod pdf_reference_document_path() {
	Renard::Incunabula::Devel::TestHelper->test_data_directory->child(qw(PDF Adobe pdf_reference_1-7.pdf));
}

=classmethod pdf_reference_document_object

Returns a L<Renard::Incunabula::Block::Format::PDF::Document> for the document located
at the path returned by L<pdf_reference_document_path>.

=cut
classmethod pdf_reference_document_object() :ReturnType(InstanceOf['Renard::Incunabula::Block::Format::PDF::Document']) {
	Renard::Incunabula::Block::Format::PDF::Document->new(
		filename => $class->pdf_reference_document_path
	);
}

1;
