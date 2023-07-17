#!/usr/bin/perl

use strict;

use FindBin qw($Bin);

sub calculate_contig_lengths {
    my $fasta_file = shift;
    open(my $fh, "<", $fasta_file) or die "Cannot open $fasta_file: $!";
    my @lengths;
    my $current_name = "";
    my $sequence_length = 0;
    while (my $line = <$fh>) {
        chomp $line;
        if ($line =~ /^>/) {
            if ($current_name ne "") {
                push @lengths, [$current_name, $sequence_length];
                $sequence_length = 0;
            }
            $current_name = $line;
            $current_name =~ s/^>//;  # Remove the leading ">"
        } else {
            $sequence_length += length($line);
        }
    }
    if ($current_name ne "") {
        push @lengths, [$current_name, $sequence_length];
    }
    close $fh;
    return @lengths;
}

my $fasta_file = shift;
my @contig_lengths = calculate_contig_lengths($fasta_file);

#print "Contig id\tContig length\n";
#foreach my $contig (@contig_lengths) {
#    my ($name, $length) = @$contig;
#    print "$name\t$length\n";
#}

# Initialize a variable to store the output
my $output = "Contig id\tContig length\n";

# Construir la salida en formato de tabla
foreach my $contig (@contig_lengths) {
    my ($name, $length) = @$contig;
    $output .= "$name\t$length\n";
}

# Save the output to a temporary file
my $output_file = 'output.txt';
open(my $fh, '>', $output_file) or die "No se pudo abrir el archivo: $!";
print $fh $output;
close($fh);

# Construct the path to the R script file
my $script_r = "$Bin/lenbyc.R";

# Command in R to be executed
my $comando_r = "Rscript $script_r \"$output_file\"";

# Run the R command
system($comando_r);
