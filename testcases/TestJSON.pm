package testcases::TestJSON;
use strict;

use base qw(testcases::base);

sub test_text_format {
    my $self=shift;

    $self->check_package('JSON') || return;

    warn "JSON tests are not implemented\n";

    ### $self->spreadsheet_test('json');
}

1;
