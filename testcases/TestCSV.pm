package testcases::TestCSV;
use strict;

use base qw(testcases::base);

sub test_text_format {
    my $self=shift;

    $self->spreadsheet_test('csv');
}

1;
