#!/usr/bin/perl

use strict;

sub calculate_N_L {
    my @sorted_lengths = @_;
    my $total_length = 0;
    foreach my $length (@sorted_lengths) {
        $total_length += $length;
    }
    
    my $half_length = $total_length / 2;
    my $sixty_percent_length = $total_length * 0.6;
    my $seventy_percent_length = $total_length * 0.7;
    my $ninety_percent_length = $total_length * 0.9;
    
    my ($n50, $l50, $n90, $l90) = (0, 0, 0, 0);
    my $accumulated_length = 0;
    my $accumulated_length_90 = 0;
    my $count = 0; # Contador de longitudes
    
    foreach my $length (@sorted_lengths) {
        $accumulated_length += $length;
        $accumulated_length_90 += $length;
        $count++;
        
        if ($accumulated_length >= $half_length && $n50 == 0) {
            $n50 = $length;
            $l50 = $count;
        }
        
        if ($accumulated_length_90 >= $ninety_percent_length && $n90 == 0) {
            $n90 = $length;
            $l90 = $count;
        }
    }
    
    return ($n50, $l50, $n90, $l90, $total_length, $count);
}


my $fasta_file = shift;
open(my $fh, "<", $fasta_file) or die "Cannot open $fasta_file: $!";
my @lengths;
my $sequence_length = 0;
while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ /^>/) {
        if ($sequence_length > 0) {
            push @lengths, $sequence_length;
            $sequence_length = 0;
        }
    } else {
        $sequence_length += length($line);
    }
}
if ($sequence_length > 0) {
    push @lengths, $sequence_length;
}
close $fh;

my ($n50, $l50, $n90, $l90, $total_length, $num_contigs) = calculate_N_L(@lengths);
print "\n\ncontig\tlength\tN50\tL50\tN90\tL90";
print "\n$num_contigs\t$total_length\t$n50\t$l50\t$n90\t$l90\n";

