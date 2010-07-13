package testcases::TestODS;
use strict;

use base qw(testcases::base);

sub test_text_format {
    my $self=shift;

    $self->check_package('Archive::Zip') || return;
    $self->check_package('XML::LibXML') || return;

    # TODO: How do we test this format output?
    #
    $self->spreadsheet_build('ods');
    ### $self->spreadsheet_test('xml');
}

1;
