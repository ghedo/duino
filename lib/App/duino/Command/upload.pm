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

sub usage_desc { '%c upload %o [sketch.ino]' }

sub opt_spec {
	my ($self) = @_;

	return (
		[ 'board|b=s', 'specify the board model',
			{ default => $self -> default_config('board') } ],

		[ 'sketchbook|s=s', 'specify the user sketchbook directory',
			{ default => $self -> default_config('sketchbook') } ],

		[ 'root|d=s', 'specify the Arduino installation directory',
			{ default => $self -> default_config('root') } ],

		[ 'port|p=s', 'specify the serial port to use',
			{ default => $self -> default_config('port') } ],

		[ 'hardware|r=s', 'specify the hardware type to build for',
			{ default => $self -> default_config('hardware') } ],
	);
}

sub execute {
	my ($self, $opt, $args) = @_;

	my $board= $opt -> board;
	my $port = $opt -> port;
	my $name = basename getcwd;

	($name = basename($args -> [0])) =~ s/\.[^.]+$//
		if $args -> [0] and -e $args -> [0];

	my $hex  = ".build/$board/$name.hex";

	$hex = $args -> [0] if $args -> [0] and $args -> [0] =~ /\.hex$/;

	my $mcu  = $self -> board_config($opt, 'build.mcu');
	my $prog = $self -> board_config($opt, 'upload.protocol');
	my $baud = $self -> board_config($opt, 'upload.speed');

	my $avrdude      = $self -> file($opt, 'hardware/tools/avrdude');
	my $avrdude_conf = $self -> file($opt, 'hardware/tools/avrdude.conf');

	print "Uploading to '" . $self -> board_config($opt, 'name') . "'...\n";

	my @avrdude_opts = (
		'-p', $mcu,
		'-C', $avrdude_conf,
		'-c', $prog,
		'-b', $baud,
		'-P', $port,
		'-U', "flash:w:$hex:i"
	);

	die "Can't find file '$hex', did you run 'duino build'?\n"
		unless -e $hex;

	open my $fh, '<', $opt -> port
		or die "Can't open serial port '" . $opt -> port . "'.\n";

	my $fd = fileno $fh;

	my $term = POSIX::Termios -> new;
	$term -> getattr($fd);

	if ($self -> board_config($opt, 'bootloader.path') eq 'caterina') {
		$term -> setispeed(&POSIX::B1200);
		$term -> setospeed(&POSIX::B1200);

		$term -> setattr($fd, &POSIX::TCSANOW);
	} else {
		require Device::SerialPort;

		my $serial = Device::SerialPort -> new($opt -> port)
			or die "Can't open serial port '" . $opt -> port . "'.\n";

		$serial -> pulse_dtr_on(0.1 * 1000.0);
	}

	close $fh;

	sleep 1;

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
