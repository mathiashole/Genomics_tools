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

# Función para mostrar la versión del programa
sub mostrar_version {
    print "Nombre del programa v1.0\n";
}

# Manejo de argumentos de línea de comandos
if (scalar(@ARGV) == 0) {
    mostrar_ayuda();
} elsif ($ARGV[0] eq '-h' || $ARGV[0] eq '--help') {
    mostrar_ayuda();
} elsif ($ARGV[0] eq '-v' || $ARGV[0] eq '--version') {
    mostrar_version();
} else {
    print "Opción desconocida. Usa '-h' o '--help' para ver la ayuda.\n";
}