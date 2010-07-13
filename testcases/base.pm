package testcases::base;
use strict;
use warnings;
use Spreadsheet::Write;
use IO::File;

use base qw(Test::Unit::TestCase);

###############################################################################

sub spreadsheet_build {
    my ($self,$format)=@_;

    my $file_test=$self->spreadsheet_filename($format,'test');

    my $sp=new Spreadsheet::Write(
        file        => $file_test,
        format      => $format,
    );

    $sp->addrow({ style => 'header', content => [
        'Column1',
        'Column#2',
        'Column 3',
        'Column  4',
    ]});

    $sp->freeze(1,0);

    for(my $i=1; $i<3; ++$i) {
        $sp->addrow(
            { style => 'ntext', content => $i },
            "Cell #2/$i",
            { font_style => 'italic', content => [ "C.3/$i", "C.4/$i/\x{263A}" ] }
        );
    }

    $sp->close;

    $self->assert(-r $file_test,
                  "Expected to have some output in $file_test");
}

###############################################################################

sub spreadsheet_filename ($$$) {
    my ($self,$format,$type)=@_;

    $self->assert($format,"Expected to have a format");

    $self->assert($type,"Expected to have a type");

    return "testcases/out/format-$format-$type.$format";
}

###############################################################################

sub spreadsheet_compare ($$) {
    my ($self,$format)=@_;

    my $file_test=$self->spreadsheet_filename($format,'test');
    my $file_ref=$self->spreadsheet_filename($format,'ref');

    $self->assert(-r $file_test,
                  "Expected to have some output in $file_test");

    $self->assert(-r $file_ref,
                  "Expected to have reference output in $file_ref");

    my $fd_test=IO::File->new($file_test,'r');
    $self->assert($fd_test ? 1 : 0,
                  "Can't open $file_test: $!");

    my @line_test=$fd_test->getlines;

    $fd_test->close;

    my $fd_ref=IO::File->new($file_ref,'r');
    $self->assert($fd_ref ? 1 : 0,
                  "Can't open $file_ref: $!");

    my @line_ref=$fd_ref->getlines;

    $fd_ref->close;

    $self->assert(scalar(@line_test)==scalar(@line_ref),
                  "Expected number of lines to be the same");

    for(my $i=0; $i<@line_test; ++$i) {
        $self->assert($line_test[$i] eq $line_ref[$i],
                      "Line $i: expected '$line_ref[$i]', got '$line_test[$i]'");
    }
}

###############################################################################

sub spreadsheet_test ($$) {
    my ($self,$format)=@_;

    $self->spreadsheet_build($format);
    $self->spreadsheet_compare($format);
}

###############################################################################

sub check_package ($$) {
    my ($self,$pkg)=@_;

    eval "use $pkg";

    if($@) {
        warn "Package '$pkg' is not available\n";
        return 0;
    }

    return 1;
}

###############################################################################

sub set_up {
    my $self=shift;

    ### chomp(my $root=`pwd`);
    ### $root.='/testcases/testroot';
    ### XAO::Base::set_root($root);
    ### push @INC,$root;
}

sub tear_down {
    my $self=shift;
}

sub timestamp ($$) {
    my $self=shift;
    time;
}

sub timediff ($$$) {
    my $self=shift;
    my $t1=shift;
    my $t2=shift;
    $t1-$t2;
}

1;
