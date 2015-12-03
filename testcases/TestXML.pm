package testcases::TestXML;
use strict;

use base qw(testcases::base);

sub test_text_format {
    my $self=shift;

    $self->check_package('XML::LibXML') || return;

    # The simple text comparison test does not work for XML because tag
    # attributes might get output in a random order. The same is true
    # for JSON. They need to be parsed and compared with something like
    # Data::Compare.
    #
    warn "XML tests are not implemented\n";
    ### $self->spreadsheet_test('xml');
}

1;
