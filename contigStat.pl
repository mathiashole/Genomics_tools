#!/usr/bin/perl

use strict;
use FindBin qw($Bin);

my @contig_data;
my $contig;

sub calculate_contig_lengths_gc {
    my $fasta_file = shift;
    open(my $fh, "<", $fasta_file) or die "Error\tCannot open $fasta_file: $!\n";
    my @contig_data;
    my $current_name = "";
    my $current_sequence = "";
    my $sequence_length = 0;
    while (my $line = <$fh>) {
        chomp $line;
        if ($line =~ /^>/) {
            if ($current_name ne "") {
                my $gc_percentage = calculate_gc_percentage($current_sequence);
                push @contig_data, [$current_name, $sequence_length, $gc_percentage];
                $current_sequence = "";
                $sequence_length = 0;
            }
            $current_name = $line;
            $current_name =~ s/^>//;  # Remove the leading ">"
        } else {
            $current_sequence .= $line;
            $sequence_length += length($line);  # Se suman las longitudes de las líneas para obtener la longitud total
        }
    }
    if ($current_name ne "") {
        my $gc_percentage = calculate_gc_percentage($current_sequence);
        push @contig_data, [$current_name, $sequence_length, $gc_percentage];
    }
    close $fh;
    return @contig_data;
}


sub calculate_gc_percentage {
    my $sequence = shift;
    my $gc_count = ($sequence =~ tr/GCgc/GCgc/);
    my $sequence_length = length($sequence);
    my $gc_percentage = ($gc_count / $sequence_length) * 100;
    return $gc_percentage;
}

my $fasta_file = shift;
my @contig_lengths = calculate_contig_lengths_gc("$fasta_file");

# Initialize a variable to store the output
my $output = "id\tlength\tGC\n";

# Construir la salida en formato de tabla
foreach my $contig (@contig_lengths) {
    my ($name, $length, $gc) = @$contig;
    $output .= "$name\t$length\t$gc\n";
    print "$name\t$length\t$gc\n";
}

# Save the output to a temporary file
my $output_file = 'output.txt';
open(my $fh, '>', $output_file) or die "Could not open the file: $!";
print $fh $output;
close($fh);

# Construct the path to the R script file
my $script_r = "$Bin/lenbyc.R";

# Command in R to be executed
my $comando_r = "Rscript $script_r \"$output_file\"";

# Run the R command
system($comando_r);
