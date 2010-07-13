package testcases::TestExcel;
use strict;

use base qw(testcases::base);

sub test_text_format {
    my $self=shift;

    $self->check_package('Spreadsheet::WriteExcel') || return;

    ### $self->spreadsheet_test('xml');

    # For Excel we'll have to be satisfied with just building the file
    # for now. Binary will probably change depending on the
    # phase of the moon?
    #
    $self->spreadsheet_build('xls');
}

1;
