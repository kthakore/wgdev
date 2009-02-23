package WGDev::Command::Test;
use strict;
use warnings;
use 5.008008;

our $VERSION = '0.0.1';

use WGDev::Command::Base;
BEGIN { our @ISA = qw(WGDev::Command::Base) }

use File::Spec ();

sub option_parse_config { return qw(gnu_getopt pass_through) }

sub option_config {
    return qw(
        all|A
        slow|S
        reset:s
    );
}

sub process {
    my $self = shift;
    my $wgd  = $self->wgd;
    require Cwd;
    require App::Prove;
    if ( $self->option('slow') ) {
        $ENV{CODE_COP}    = 1;
        $ENV{TEST_SYNTAX} = 1;
        $ENV{TEST_POD}    = 1;
    }
    if ( defined $self->option('reset') ) {
        my $reset_options = $self->option('reset');
        if ($reset_options eq '') {
            $reset_options = '--quiet --delcache --import --upgrade';
        }
        require WGDev::Command::Reset;
        my $reset = WGDev::Command::Reset->new($wgd);
        $reset->parse_params_string($reset_options);
        $reset->process;
    }
    my $prove = App::Prove->new;
    my @args  = $self->arguments;
    my $orig_dir;
    if ( $self->option('all') ) {
        $orig_dir = Cwd::cwd();
        chdir $wgd->root;
        unshift @args, '-r', 't';
    }
    $prove->process_args(@args);
    my $result = $prove->run;
    if ($orig_dir) {
        chdir $orig_dir;
    }
    return $result;
}

1;

__END__

=head1 NAME

WGDev::Command::Test - Run WebGUI tests

=head1 SYNOPSIS

wgd test [-AS] [<prove options>]

=head1 DESCRIPTION

Runs WebGUI tests, setting the needed environment variables beforehand.
Includes quick options for running all tests, and including slow tests.

=head1 OPTIONS

Unrecognized options will be passed through to prove.

=over 8

=item B<-A --all>

Run all tests recursively.  Otherwise, tests will need to be specified.

=item B<-S --slow>

Includes slow tests by defining CODE_COP, TEST_SYNTAX, and TEST_POD.

=item B<--reset=>

Perform a site reset before running the tests.  The value specified is used
as the command line parameters for the reset command.  With no value, will use
the --delcache --import --upgrade parameters to do a fast site reset.

=back

=head1 AUTHOR

Graham Knop <graham@plainblack.com>

=head1 LICENSE

Copyright (c) Graham Knop.  All rights reserved.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

