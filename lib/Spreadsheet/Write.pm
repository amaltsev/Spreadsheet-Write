package Spreadsheet::Write;

require 5.002;

use strict;
use IO::File;
use Text::CSV;
use Encode;
use Spreadsheet::WriteExcel;

BEGIN {
  use vars       qw($VERSION);
  $VERSION =     '0.01';
}

sub version {
  return $VERSION;
}

sub new(@) {
    my $proto = shift;
    my $args={@_};

    my $class = ref($proto) || $proto;
    my $self = {};

    my $filename=$args->{'file'};
    bless $self, $class;

    if(!($self->{'_FILENAME'}=$args->{'file'})) {
        $self->{'_ERROR'}='No file given';
        return $self;
    }

    $self->{'_SHEETNAME'}=$args->{'sheet'} || '';

    my $format=$args->{'format'};
    if(!$format && $filename=~/\.(.*)$/) {
        $format=lc($1);
    }
    $format='csv' if(!$format);
    if(($format ne 'csv') && ($format ne 'xls')) {
        $self->{'_ERROR'}="Format $format is not supported";
        return $self;
    }
    $self->{'_FORMAT'}=$format;
    $self->{'_ERROR'}='';

    $self->_open();
    
    return $self;
}

sub error {
    my $self=shift;
    return $self->{'_ERROR'};
    
}

sub _open($) {
    my $self=shift;

    my $fh=$self->{'_FH'};

    if(!$fh) {
        my $filename=$self->{'_FILENAME'} || return undef;
        $fh=new IO::File;
        if(!$fh->open($filename,"w")) {
            $self->{'_ERROR'}="Can't open file $filename for writing: $!";
            return undef;
        }
        $self->{'_FH'}=$fh;
    }

    if($self->{'_FORMAT'} eq 'xls') {
        my $worksheet=$self->{'_WORKSHEET'};
        my $workbook=$self->{'_WORKBOOK'};
        if(!$worksheet) {
            $fh->binmode();
            $workbook=Spreadsheet::WriteExcel->new($fh);
            $self->{'_WORKBOOK'}=$workbook;
            $worksheet = $workbook->add_worksheet($self->{'_SHEETNAME'});
            $self->{'_WORKSHEET'}=$worksheet;
            $self->{'_WORKBOOK_ROW'}=0;
        }
    }
    elsif($self->{'_FORMAT'} eq 'csv') {
        $self->{'_CSV_OBJ'}||=Text::CSV->new;
    }
    return $self;
}

sub addrow (@) {
    my $self=shift;
    my $parts=\@_;
    
    my @texts;
    my @props;

    $self->_open() || return undef;
    
    foreach my $part (@$parts) {
        if(ref($part) && (ref($part) eq 'HASH')) {
            push(@texts,$part->{'content'} || '');
            push(@props,$part);
        }
        else {
            push(@texts,$part);
            push(@props,undef);
        }
    }
    if($self->{'_FORMAT'} eq 'csv') {
        my $string;
        my $nparts=scalar(@texts);
        for(my $i=0; $i<$nparts; $i++) {
            $texts[$i]=~s/([^\x20-\x7e])/'&#' . ord($1) . ';'/esg;
        }

        if(!$self->{'_CSV_OBJ'}->combine(@texts)) {
            $self->{'_ERROR'}="csv_combine failed at ".$self->{'_CSV_OBJ'}->error_input();
            return undef;
        }
        $string=$self->{'_CSV_OBJ'}->string();
        $string=~s/&#(\d+);/chr($1)/esg;
        $string=Encode::decode('utf8',$string) unless Encode::is_utf8($string);
        $string=Encode::encode($self->{'_ENCODING'} || 'utf8',$string);
        $self->{'_FH'}->write($string."\n");
        $self->{'_ERROR'}='';
        return $self;
    }
    elsif($self->{'_FORMAT'} eq 'xls') {
        my $worksheet=$self->{'_WORKSHEET'};
        my $workbook=$self->{'_WORKBOOK'};
        my $row=$self->{'_WORKBOOK_ROW'};
        my $col=0;
        my $nparts=scalar(@texts);
        for(my $i=0; $i<$nparts; $i++) {
            my $string=$texts[$i];
            my $props=$props[$i];
            my %format;
            if($props) {
                if($props->{'font_weight'}) {
                    if($props->{'font_weight'} eq 'bold') {
                        $format{'bold'}=1;
                    }
                }
                if($props->{'font_style'}) {
                    if($props->{'font_style'} eq 'italic') {
                        $format{'italic'}=1;
                    }
                }
                my $decor=$props->{'font_decoration'};
                if($decor) {
                    if($decor eq 'underline') {
                        $format{'underline'}=1;
                    }
                    elsif($decor eq 'strikeout') {
                        $format{'font_strikeout'}=1;
                    }
                }
                if($props->{'font_color'}) {
                    $format{'color'}=$props->{'font_color'};
                }
                if($props->{'font_face'}) {
                    $format{'font'}=$props->{'font_face'};
                }
                if($props->{'font_size'}) {
                    $format{'size'}=$props->{'font_size'};
                }
                if($props->{'align'}) {
                    $format{'align'}=$props->{'align'};
                }
                if($props->{'valign'}) {
                    $format{'valign'}=$props->{'valign'};
                }
            }
            if(keys %format > 0) {
                $worksheet->write($row, $col++, $string, $workbook->add_format(%format));
            }
            else {
                $worksheet->write($row, $col++, $string);
            }
        }
        $self->{'_WORKBOOK_ROW'}++;
    }
    return $self;
}

sub freeze (@) {
    my $self=shift;
    
    $self->_open() || return undef;
    $self->{'_WORKSHEET'}->freeze_panes(@_);

    return $self;
}

1;
__END__

=head1 NAME

Spreadsheet::Write - Simplyfied write rows into CSV or XLS file

=head1 SYNOPSIS

    # EXCEL spreadsheet
    
    use Spreadsheet::Write;

    my $h=Spreadsheet::Write->new(
        file    => 'spreadsheet',
        format  => 'xls',
        sheet   => 'Products',
    );

    die $h->error() if $h->error;
    
    $h->addrow('foo',{
        contet          => 'bar',
        font_weight     => 'bold',
        font_color      => 42,
        font_face       => 'Times New Roman',
        font_size       => 20,
        align           => 'center',
        valign          => 'vcenter',
        font_decoration => 'strikeout',
        font_style      => 'italic',
    });
    $h->addrow('foo2','bar2');
    $h->freeze(1,0);


    # CSV file

    use Spreadsheet::Write;

    my $h=Spreadsheet::Write->new(
        file        => 'file.csv',
        encoding    => 'iso8859',
    );
    die $h->error() if $h->error;
    $h->addrow('foo','bar');
    
    
    
=head1 DESCRIPTION

C<Spreadsheet::Write> writes files in csv or xls formats.

=head1 METHODS

=head2 new()

    $spreadsheet = Spreadsheet::Write->new();

Creates a new spreadsheet object. It takes a list of options. The
following are valid:

    file        filename of new spreadsheet (mandatory)
    encoding    encoding of output file (optional, csv format only)
    format      format of spreadsheet ('csv' or 'xls'). If omitted, format
                is guessed from filename extention or csv (default)
    sheet       Sheet name (optional, xls format only)
    
=head2 addrow(arg1,arg2,...)

Adds a row into opened spreadsheet. Takes arbitrary number of arguments. Arguments is a
column values and may be strings or hash references.
If argument is a hash reference, additional optional parameters may be passed:

    content         string to put into column
    font_weight     weight of font. Only valid value is 'bold'
    font_style      style of font. Only valid value is 'italic'
    font_decoration 'underline' or 'strikeout'
    font_face       font of column; default is 'Arial'
    font_color      color of font. See Spreadsheet::WriteExcel for color values description
    font_size       size of font
    align           alignment
    valign          vertical alignment
    
=head2 freeze($row, $col, $top_row, $left_col))

    equal to Spreadsheet::WriteExcel->freeze_panes()
    
=cut
