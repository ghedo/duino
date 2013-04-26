package App::duino::Command::models;

use strict;
use warnings;

use App::duino -command;

=head1 NAME

App::duino::Command::models - List all known Arduino models

=head1 SYNOPSIS

  $ duino models

=cut

sub abstract { 'list all known Arduino models' }

sub usage_desc { '%c models %o' }

sub opt_spec {
	my ($self) = @_;

	return (
		[ 'root|d=s', 'specify the Arduino installation directory',
			{ default => $self -> default_config('root') } ],
	);
}

sub execute {
	my ($self, $opt, $args) = @_;

	my $boards = $self -> file($opt, 'hardware/arduino/boards.txt');

	open my $fh, '<', $boards
		or die "Can't open file 'boards.txt'.\n";

	print "Supported models:\n\n";

	while (my $line = <$fh>) {
		chomp $line;

		my $first = substr $line, 0, 1;

		next if $first eq '#' or $first eq '';
		next unless $line =~ /^(.*)\.name\=/;

		my $board = $1;

		my (undef, $value) = split '=', $line;

		printf "%10s: %s\n", $board, $value;
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

1; # End of App::duino::Command::models
