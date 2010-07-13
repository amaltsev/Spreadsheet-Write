package testcases::TestXML;
use strict;

use base qw(testcases::base);

sub test_text_format {
    my $self=shift;

    $self->spreadsheet_test('xml');
}

1;
