#!/usr/bin/perl

use strict;

sub calculate_n50_l50 {
    my @lengths = @_;
    my @sorted_lengths = sort { $b <=> $a } @lengths;
    my $total_length = 0;
    foreach my $length (@sorted_lengths) {
        $total_length += $length;
    }
    my $half_length = $total_length / 2;
    my $accumulated_length = 0;
    my $n50 = 0;
    my $l50 = 0;
    foreach my $length (@sorted_lengths) {
        $accumulated_length += $length;
        if ($accumulated_length >= $half_length) {
            $n50 = $length;
            $l50 = scalar(@sorted_lengths) - $l50 + 1;
            last;
        }
        $l50++;
    }
    return ($n50, $l50, $total_length, scalar(@lengths));
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

my ($n50, $l50, $total_length, $num_contigs) = calculate_n50_l50(@lengths);
print "\n\nlength\tcontigs\tN50\tL50\n";
print "$total_length\t$num_contigs\t$n50\t$l50\n";

