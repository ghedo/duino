package App::duino::Command::clean;

use strict;
use warnings;

use App::duino -command;

use File::Path qw(remove_tree);

=head1 NAME

App::duino::Command::clean - Clean the build directory

=head1 SYNOPSIS

  $ duino clean --board uno

=cut

sub abstract { 'clean the build directory' }

sub usage_desc { '%c clean %o' }

sub opt_spec {
	my $arduino_board       = $ENV{'ARDUINO_BOARD'} || 'uno';

	if (-e 'duino.ini') {
		my $config = Config::INI::Reader -> read_file('duino.ini');

		$arduino_board = $config -> {'_'} -> {'board'}
			if $config -> {'_'} -> {'board'};
	}

	return (
		[ 'board|b=s', 'specify the board model',
			{ default => $arduino_board } ],
	);
}

sub execute {
	my ($self, $opt, $args) = @_;

	my $board_name = $opt -> board;

	remove_tree(".build/$board_name/");
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

1; # End of App::duino::Command::clean
