#!/usr/bin/perl -w
use strict;

my $intxt=shift;
my $anno_version=shift;
my $genome_version=shift;

$anno_version ||="Test";
$genome_version ||="AP000423.1";

my %exon_hash;
open IN, "$intxt" || die "$!\n";
while(<IN>){
  chomp;
  my @info=split;
  if($info[1] eq "exon"){
    #print "$_\n";
    if($info[3] eq "+"){
      $info[4]++;
      $info[5]++;
    }
    push @{$exon_hash{$info[0]}{$info[3]}}, [@info];
  }
}
close IN;

foreach my $gene(sort keys %exon_hash){
  #print "$gene\n";

  foreach my $s(sort keys %{$exon_hash{$gene}}){
    #print "$gene\t$s\n";

    @{$exon_hash{$gene}{$s}} = sort {$a -> [4] <=> $b -> [4]} @{$exon_hash{$gene}{$s}};

    my $gene_start=$exon_hash{$gene}{$s}[0][4];
    my $gene_end=$exon_hash{$gene}{$s}[-1][5];
    my $gid="$gene\_$s";
    #print "$gid\n";

    print "$genome_version\t$anno_version\tgene\t$gene_start\t$gene_end\t\.\t$s\t\.\tID=$gid;\n";
    for (my $i=0; $i<@{$exon_hash{$gene}{$s}}; $i++){
      print "$genome_version\t$anno_version\texon\t$exon_hash{$gene}{$s}[$i]->[4]\t$exon_hash{$gene}{$s}[$i]->[5]\t\.\t$s\t\.\tParent=$gid;\n";
    }
  }
}
