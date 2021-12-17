#!/usr/bin/perl -w
use strict;

my $intxt=shift;
my $genome_fa=shift;
#my $genome_ID=shift;
my $anno_version=shift;

$anno_version ||="Test";
#$genome_ID ||="AP000423.1";

open IN, "$genome_fa" || die "$!\n";
$/=">";
<IN>;
$/="\n";
my $head=<IN>;
my $genome_ID=$1 if ($head =~ /^(\S+)/);
$/=">";
my $seq=<IN>;
chomp($seq);
$seq=~s/\s+//g;
$seq=~tr/atcg/ATCG/;
my $genome_length=length($seq);
$/="\n";
close IN;
#print "$genome_ID\t$genome_length\n";

my %exon_hash;
open IN, "$intxt" || die "$!\n";
while(<IN>){
  chomp;
  #print "$_\n";
  next if(/^gene/);

  my @info=split;
  #print "$info[0]\t$info[3]\n";
  if($info[1] eq "exon"){
    #print "$_\n";

    #$info[3] = ($info[3] eq 'f') ? ("+") :("-");

    # stop sites
    $info[6] = $info[4] + $info[5] - 1;

    if($info[3] eq "+"){
      # 0-based coordinates
      #$info[4]++;
      #$info[6]++;
    }else{
      # transform coordinates to be general ones.
      #my $len=$genome_length("$genome_ID");
      # 0-based coordinates
      #$info[4]=$genome_length-$info[4];
      #$info[6]=$genome_length-$info[6];
      # 1-based coordinates
      $info[4]=$genome_length-$info[4]+1;
      $info[6]=$genome_length-$info[6]+1;
    }
    ($info[4], $info[6])=($info[4] > $info[6]) ? ($info[6], $info[4]) : ($info[4], $info[6]);

    #print "$info[0]\t$info[3]\n";
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
    my $gene_end=$exon_hash{$gene}{$s}[-1][6];
    my $gid="$gene\_$gene_start";
    #print "$gid\n";

    print "$genome_ID\t$anno_version\tgene\t$gene_start\t$gene_end\t\.\t$s\t\.\tID=$gid;\n";
    for (my $i=0; $i<@{$exon_hash{$gene}{$s}}; $i++){
      print "$genome_ID\t$anno_version\texon\t$exon_hash{$gene}{$s}[$i]->[4]\t$exon_hash{$gene}{$s}[$i]->[6]\t\.\t$s\t\.\tParent=$gid;\n";
    }
  }
}
