package testcases::TestHTML;
use strict;

use base qw(testcases::base);

sub test_text_format {
    my $self=shift;

    $self->check_package('HTML::HTML5::Writer') || return;

    warn "HTML tests are not implemented\n";

    ### $self->spreadsheet_test('html');
}

1;
