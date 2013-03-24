package App::duino::Command;

use strict;
use warnings;

use App::Cmd::Setup -command;

=head1 NAME

App::duino::Command - Base class for App::duino commands

=cut

sub opt_spec {
	return (
		[ 'board=s', 'set the board model', { default => 'uno' } ],
		[ 'port=s', 'set the serial port to use', { default => undef } ],
		[ 'path=s', 'set Arduino base directory', { default => '/usr/share/arduino' } ]
	);
}

sub config {
	my ($self, $opt, $config) = @_;

	my $board = $opt -> board;

	my $base   = $opt -> path;
	my $boards = "$base/hardware/arduino/boards.txt";

	open my $fh, '<', $boards or die "open()";

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
