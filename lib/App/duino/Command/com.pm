package App::duino::Command::com;

use strict;
use warnings;

use App::duino -command;

use Device::SerialPort;

=head1 NAME

App::duino::Command::com - Open a serial monitor to an Arduino

=head1 SYNOPSIS

  $ duino com --port /dev/ttyACM0

=cut

sub abstract { 'open a serial monitor to an Arduino' }

sub usage_desc { '%c upload %o [sketch.ino]' }

sub opt_spec {
	my $arduino_port        = $ENV{'ARDUINO_PORT'}  || '/dev/ttyACM0';

	return (
		[ 'port|p=s', 'specify the serial port to use',
			{ default => $arduino_port } ],
	);
}

sub execute {
	my ($self, $opt, $args) = @_;

	open my $fh, '<', $opt -> port
		or die "Can't open serial port '" . $opt -> port . "'.\n";

	my $fd = fileno $fh;

	while (read $fh, my $char, 1) {
		print $char;
	}

	close $fh;
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

1; # End of App::duino::Command::com
