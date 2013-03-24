package App::duino::Command::upload;

use strict;
use warnings;

use App::duino -command;

use Cwd;
use POSIX;
use File::Basename;

=head1 NAME

App::duino::Command::upload - Upload a sketch to an Arduino

=head1 SYNOPSIS

  $ duino upload --board uno --port /dev/ttyACM0

=cut

sub abstract { 'upload a sketch to an Arduino' }

sub usage_desc { '%c upload %o' }

sub execute {
	my ($self, $opt, $args) = @_;

	open my $fh, '<', $opt -> port or die "open()";
	my $fd = fileno $fh;

	my $term = POSIX::Termios -> new;
	$term -> getattr($fd);

	if ($self -> config($opt, 'bootloader.path') eq 'caterina') {
		$term -> setispeed(&POSIX::B1200);
		$term -> setospeed(&POSIX::B1200);

		$term -> setattr($fd, &POSIX::TCSANOW);
	} else {
		require Device::SerialPort;

		my $serial = Device::SerialPort -> new($opt -> port)
			or die "serial";

		$serial -> pulse_dtr_on(0.1 * 1000.0);
	}

	close $fh;

	sleep 1;

	my $base = $opt -> path;
	my $board= $opt -> board;
	my $port = $opt -> port;
	my $name = basename getcwd;
	my $hex  = ".build/$board/$name.hex";
	my $mcu  = $self -> config($opt, 'build.mcu');
	my $prog = $self -> config($opt, 'upload.protocol');
	my $baud = $self -> config($opt, 'upload.speed');

	my $avrdude      = "$base/hardware/tools/avrdude";
	my $avrdude_conf = "$base/hardware/tools/avrdude.conf";
	my @avrdude_opts = (
		'-p', $mcu,
		'-C', $avrdude_conf,
		'-c', $prog,
		'-b', $baud,
		'-P', $port,
		'-U', "flash:w:$hex:i"
	);

	system $avrdude, @avrdude_opts;
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

1; # End of App::duino::Command::upload
