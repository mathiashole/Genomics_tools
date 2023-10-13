#!/usr/bin/perl

use strict;
use FindBin qw($Bin);
use File::Basename;
use Getopt::Long;

# define flag
my $stat_flag = 0;
my $length_flag = 0;
my $help_flag = 0;
my $version_flag = 0;

# name of flag
GetOptions(
    "stat" => \$stat_flag,
    "length" => \$length_flag,
    "help" => \$help_flag,
    "version" => \$version_flag
);

# Function to show help
sub show_help {
    print <<'HELP';
Use: GStat [OPTIONS]

 Opciones disponibles:
    -help, --help     Show this help.
    -version, --version  Show the version of the program.
    -length, --length   Show and save lengths of contigs.
    -stat, --stat    Show N50 and L50 of genome.
    # Missing options

 Examples:
    main.pl -help
    main.pl -version
HELP
}

# Function to show the version of the program
sub show_version {
    print "GStat v0.0.1\n";
}

# Handling command line arguments
if (scalar(@ARGV) == 0) {
    show_help();
} elsif ($help_flag) {
    show_help();
} elsif ($version_flag) {
    show_version();
} elsif ($length_flag) {
    
    # Verify that a second argument is supplied
    die "Error: Missing FASTA file. Usage: perl main.pl -l <fasta_file>\n" unless @ARGV == 1;

    # Get the name of the FASTA file given as an argument
    my $fasta_file = $ARGV[0];

    die "Error: File '$fasta_file' not found.\n" unless -e $fasta_file; # -e chack for file existence

    my ($file_name, $file_path, $file_ext) = fileparse($fasta_file, qr/\.[^.]*/); # \. = dot in file name. [^.]* = any sequence followed by a dot
    
    die "Error: File '$fasta_file' is not in FASTA format.\n" unless $file_ext =~ /^\.fasta|\.fa$/i;

    # Construct the path to the perl script file
    my $script_length = "$Bin/contigStat.pl";

    # Command in perl to be executed
    my $comando_length = "perl $script_length \"$fasta_file\"";

    # Run the perl command
    system($comando_length);

} elsif ($stat_flag) {

    calculate_stats_for_files(@ARGV);

} else {

    print "Unknown option. Use '-help' or '--help' to display help.\n";

}

sub calculate_stats_for_files {
    my @args = @_;

    my $script_n50 = "$Bin/GStat.pl";

    # Command in perl to be executed
    my $comando_n50 = "perl $script_n50 @_";

    # Run the perl command
    system($comando_n50);
}