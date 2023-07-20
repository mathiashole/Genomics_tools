#!/usr/bin/perl

use strict;

# Function to show help
sub show_help {
    print <<'HELP';
Use: GStat [OPTIONS]

Opciones disponibles:
    -h, --help     Show this help.
    -v, --version  Show the version of the program.
    # Missing options

Examples:
    main.pl -h
    main.pl -v
HELP
}

# Function to show the version of the program
sub show_version {
    print "GStat v0.0.1\n";
}

# Handling command line arguments
if (scalar(@ARGV) == 0) {
    show_help();
} elsif ($ARGV[0] eq '-h' || $ARGV[0] eq '--help') {
    show_help();
} elsif ($ARGV[0] eq '-v' || $ARGV[0] eq '--version') {
    show_version();
} else {
    print "Unknown option. Use '-h' or '--help' to display help.\n";
}