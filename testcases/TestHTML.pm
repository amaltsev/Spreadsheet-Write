package testcases::TestHTML;
use strict;

use base qw(testcases::base);

sub test_text_format {
    my $self=shift;

    $self->check_package('HTML::HTML5::Writer') || return;

    $self->spreadsheet_test('html');
}

1;
