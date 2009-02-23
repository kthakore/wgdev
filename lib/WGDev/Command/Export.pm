package WGDev::Command::Export;
use strict;
use warnings;
use 5.008008;

our $VERSION = '0.1.0';

use WGDev::Command::Base;
BEGIN { our @ISA = qw(WGDev::Command::Base) }
use Carp qw(croak);

sub option_config {
    return qw(
        stdout
    );
}

sub process {
    my $self = shift;

    my $wgd_asset = $self->wgd->asset;
    for my $asset_spec ( $self->arguments ) {
        my $asset = eval { $wgd_asset->find($asset_spec) }
            || eval { $wgd_asset->validate_class($asset_spec) };
        if ( !$asset ) {
            warn $@;    ##no critic (RequireCarping)
            next;
        }
        my $asset_text = $self->wgd->asset->serialize($asset);
        if ( $self->option('stdout') ) {
            print $asset_text;
        }
        else {
            my $filename = $self->export_filename($asset);
            print "Writing $filename...\n";
            open my $fh, '>', $filename
                or croak "Unable to write to $filename\: $!";
            print {$fh} $asset_text;
            close $fh or croak "Unable to write to $filename\: $!";
        }
    }
    return 1;
}

sub export_filename {
    my $self        = shift;
    my $asset       = shift;
    my $class       = ref $asset || $asset;
    my $short_class = $class;
    $short_class =~ s/.*:://msx;
    my $extension = lc $short_class;
    $extension =~ tr/aeiouy//d;
    $extension =~ tr/a-z//s;
    my $filename;

    if ( ref $asset ) {
        $filename = ( split m{/}msx, $asset->get('url') )[-1];
    }
    else {
        $filename = 'new-' . lc $short_class;
    }
    $filename .= ".$extension";
    return $filename;
}

1;

__END__

=head1 NAME

WGDev::Command::Export - Exports assets to files

=head1 SYNOPSIS

    wgd export [--stdout] <asset> [<asset> ...]

=head1 DESCRIPTION

Exports asset to files.

=head1 OPTIONS

=over 8

=item B<--stdout>

Exports to standard out instead of a file.  This only makes sense with a single asset specified.

=item B<E<lt>assetE<gt>>

Either an asset URL, ID, class name.  As many can be specified as desired.
Prepending with a slash will force it to be interpreted as a URL.  Asset
classes will generate skeletons of export files for the given class.

=back

=head1 AUTHOR

Graham Knop <graham@plainblack.com>

=head1 LICENSE

Copyright (c) Graham Knop.  All rights reserved.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
