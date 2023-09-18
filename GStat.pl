#!/usr/bin/perl

use strict;
use File::Basename;

main();

# my @fasta_files = @ARGV;


# # Verificar si se proporcionaron archivos FASTA
# if (@fasta_files == 0) {
#     die("Uso: $0 <archivo1.fasta> <archivo2.fasta> ...\n");
# }

# # Crear un arreglo de hashes para almacenar los resultados de múltiples genomas
# my @genomes_data;

# foreach my $fasta_file (@fasta_files) {
#     my $new_fasta = basename($fasta_file);
#     open(my $fh, "<", $fasta_file) or die "Cannot open $fasta_file: $!";
#     my @lengths;
#     my $sequence_length = 0;
#     while (my $line = <$fh>) {
#         chomp $line;
#         if ($line =~ /^>/) {
#             if ($sequence_length > 0) {
#                 push @lengths, $sequence_length;
#                 $sequence_length = 0;
#             }
#         } else {
#             $sequence_length += length($line);
#         }
#     }
#     if ($sequence_length > 0) {
#         push @lengths, $sequence_length;
#     }
#     close $fh;

#     my ($n50, $l50, $n60, $l60, $n70, $l70, $n90, $l90, $total_length, $num_contigs) = calculate_N_L(@lengths);
#     push @genomes_data, {
#         fasta_file => $new_fasta,
#         num_contigs => $num_contigs,
#         total_length => $total_length,
#         n50 => $n50,
#         l50 => $l50,
#         n60 => $n60,
#         l60 => $l60,
#         n70 => $n70,
#         l70 => $l70,
#         n90 => $n90,
#         l90 => $l90,
#     };
# }

# # Imprimir los resultados en formato tabular
# #print "\nGenoma\tContigs\tTotal_Length\tN50\tL50\tN60\tL60\tN70\tL70\tN90\tL90\n";
# foreach my $genome (@genomes_data) {
#     printf("%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n",
#         $genome->{fasta_file},
#         $genome->{num_contigs},
#         $genome->{total_length},
#         $genome->{n50},
#         $genome->{l50},
#         $genome->{n60},
#         $genome->{l60},
#         $genome->{n70},
#         $genome->{l70},
#         $genome->{n90},
#         $genome->{l90}
#     );
# }

sub process_fasta_file {
    my ($fasta_file) = @_;

    my $new_fasta = basename($fasta_file);
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

    my ($n50, $l50, $n60, $l60, $n70, $l70, $n90, $l90, $total_length, $num_contigs) = calculate_N_L(@lengths);
    return {
        fasta_file => $new_fasta,
        num_contigs => $num_contigs,
        total_length => $total_length,
        n50 => $n50,
        l50 => $l50,
        n60 => $n60,
        l60 => $l60,
        n70 => $n70,
        l70 => $l70,
        n90 => $n90,
        l90 => $l90,
    };
}

sub main {
    my @fasta_files = @ARGV;

    # Verificar si se proporcionaron archivos FASTA
    if (@fasta_files == 0) {
        die("Uso: $0 <archivo1.fasta> <archivo2.fasta> ...\n");
    }

    my @genomes_data;

    # Procesa cada archivo FASTA y guarda los resultados en un arreglo
    foreach my $fasta_file (@fasta_files) {
        my $genome_data = process_fasta_file($fasta_file);
        push @genomes_data, $genome_data;
    }

    # Abre el archivo de salida en modo de agregado para no reemplazar los datos anteriores
    open(my $output_fh, ">>", "output_stat_genome.txt") or die "Cannot open output file: $!";

    # Imprime encabezados de columna en el archivo de salida si es la primera vez
    if (-s "output_stat_genome.txt" == 0) {
        print $output_fh "Genoma\tContigs\tTotal_Length\tN50\tL50\tN60\tL60\tN70\tL70\tN90\tL90\n";
    }

    # Escribe los resultados en el archivo de salida
    foreach my $genome (@genomes_data) {
        printf($output_fh "%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n",
            $genome->{fasta_file},
            $genome->{num_contigs},
            $genome->{total_length},
            $genome->{n50},
            $genome->{l50},
            $genome->{n60},
            $genome->{l60},
            $genome->{n70},
            $genome->{l70},
            $genome->{n90},
            $genome->{l90}
        );
    }

    # Cierra el archivo de salida
    close $output_fh;

    print "Resultados acumulados en 'output_stat_genome.txt'\n";
}


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
    
    my ($n50, $l50, $n60, $l60, $n70, $l70,$n90, $l90) = (0, 0, 0, 0, 0, 0, 0, 0);
    my $accumulated_length = 0;
    my $accumulated_length_60 = 0;
    my $accumulated_length_70 = 0;
    my $accumulated_length_90 = 0;
    my $count = 0; # Contador de longitudes
    
    foreach my $length (@sorted_lengths) {
        $accumulated_length += $length;
        $accumulated_length_60 += $length;
        $accumulated_length_70 += $length;
        $accumulated_length_90 += $length;
        $count++;
        
        if ($accumulated_length >= $half_length && $n50 == 0) {
            $n50 = $length;
            $l50 = $count;
        }

        if ($accumulated_length_60 >= $sixty_percent_length && $n60 == 0) {
            $n60 = $length;
            $l60 = $count;
        }
        
        if ($accumulated_length_70 >= $seventy_percent_length && $n70 == 0) {
            $n70 = $length;
            $l70 = $count;
        }

        if ($accumulated_length_90 >= $ninety_percent_length && $n90 == 0) {
            $n90 = $length;
            $l90 = $count;
        }
    }
    
    return ($n50, $l50, , $n60, $l60, , $n70, $l70, $n90, $l90, $total_length, $count);
}