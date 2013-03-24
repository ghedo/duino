package App::duino::Command::clean;

use strict;
use warnings;

use App::duino -command;

use File::Path qw(remove_tree);

=head1 NAME

App::duino::Command::clean - Clean the build directory for a specific board

=head1 SYNOPSIS

  $ duino clean --board uno

=cut

sub abstract { 'clean the build directory for a specific board' }

sub usage_desc { '%c clean %o' }

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
