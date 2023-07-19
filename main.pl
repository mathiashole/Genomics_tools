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

show_help()