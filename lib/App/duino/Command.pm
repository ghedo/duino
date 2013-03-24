package App::duino::Command;

use strict;
use warnings;

use App::Cmd::Setup -command;

use File::Basename;

=head1 NAME

App::duino::Command - Base class for App::duino commands

=cut

sub opt_spec {
	my $arduino_dir         = $ENV{'ARDUINO_DIR'}   || '/usr/share/arduino';
	my $arduino_board       = $ENV{'ARDUINO_BOARD'} || 'uno';
	my $arduino_port        = $ENV{'ARDUINO_PORT'}  || '/dev/ttyACM0';
	my $arduino_sketchbook  = $ENV{'ARDUINO_SKETCHBOOK'} ||
						"$ENV{'HOME'}/sketchbook";

	return (
		[ 'board|b=s', 'set the board model',
			{ default => $arduino_board } ],
		[ 'port|p=s', 'set the serial port to use',
			{ default => $arduino_port } ],
		[ 'sketchbook|s=s', 'set the user sketchbook directory',
			{ default => $arduino_sketchbook } ],
		[ 'dir|d=s', 'set the Arduino installation directory',
			{ default => $arduino_dir } ]
	);
}

sub config {
	my ($self, $opt, $config) = @_;

	my $board = $opt -> board;

	my $boards = $self -> file($opt, 'hardware/arduino/boards.txt');

	open my $fh, '<', $boards
		or die "Can't open 'boards.txt' file.\n";

	my $value = undef;

	while (my $line = <$fh>) {
		chomp $line;

		my $first = substr $line, 0, 1;

		next if $first eq '#' or $first eq '';
		next unless $line =~ /^$board\.$config\=/;

		(undef, $value) = split '=', $line;
	}

	close $fh;

	return $value;
}

sub file {
	my ($self, $opt, $file) = @_;

	my $path = $opt -> dir . '/' . $file;

	return $path if -e $path;

	die "Can't find '" . basename($file) . "' file.\n";
}

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of App::duino::Command
