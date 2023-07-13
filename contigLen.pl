#!/usr/bin/perl

use strict;

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

my $contigResult = "Contig id\tContig length\n";  # Variable to store the contigResult
foreach my $contig (@contig_lengths) {
    my ($name, $length) = @$contig;
    $contigResult .= "$name\t$length\n";  # Concatenate each result line to the $contigResult variable
}

# R program from Perl
my $r_script = "lenbyc.R";

# Run R script from Perl
system("Rscript $r_script $contigResult");