package testcases::TestODS;
use strict;

use base qw(testcases::base);

sub test_text_format {
    my $self=shift;

    $self->check_package('Archive::Zip') || return;
    $self->check_package('XML::LibXML') || return;

    warn "ODS tests are not implemented\n";

    ### $self->spreadsheet_build('ods');
}

1;
