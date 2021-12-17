#!/usr/bin/perl -w
use strict;

my $input_genbank_file=shift;

my %exon_loci;
$/="\/";
open IN, "$input_genbank_file" || die "$!\n";
while(<IN>){
  #$line_number++;
  chomp;
  if(/\s+CDS\s+.+\.\.|\s+tRNA\s+.+\.\.|\s+rRNA\s+.+\.\./){
    my $input_1st_line=$_;
    my $strand=(/complement/) ? ("-") : ("+");

    my $input_2nd_line=<IN>;
    #$line_number++;
    #chomp($input_2nd_line);
    #if($input_2nd_line=~/gene=\"(\S+)\"/ && $input_2nd_line !~ /rps12/){
    if($input_2nd_line=~/gene=\"(\S+)\"/){
      my $gene=$1;

      # assign a unique ID for each gene copy, 'cause some genes have more than one copy!
      my $gene_start_as_mark=$1 if($input_1st_line=~/(\d+)\.\./);
      $gene .="_$gene_start_as_mark";

      $input_1st_line=~s/\<|\>//g; # avoid the following case: complement(117525..>119027)
      my @info=split(/,/, $input_1st_line);

      my $last_exon_end;
      for(my $i=0; $i<@info; $i++){
        if($info[$i]=~/(\d+)\.\.(\d+)/){
          #print "$gene\t$1\_$2\n";
          my ($exon_start, $exon_end)=($1<$2) ? ($1, $2) : ($2, $1);

          # store exon positions
          push @{$exon_loci{$gene}}, [$exon_start, $exon_end, $strand];
          #if ($1<$2){
          #  push @{$exon_loci{$gene}}, [$1, $2, $strand];
          #\}else{
          #  push @{$exon_loci{$gene}}, [$2, $1, $strand];
          #  print STDERR "$1\_$2\t#please check the coordinates!";
          #}
        }
      }
      #print "$gene\t$strand\t$exon_start_list\t$exon_end_list\t$input_1st_line\n";
    }else{
      print STDERR "$input_2nd_line\t#strange formats need to be checked further!\n";
    }
  }
}
close IN;

#foreach my $gene(sort keys %exon_loci){
#  print "$gene\n";
#}

$/="     gene";
open IN2, "$input_genbank_file" || die "$!\n";
while(<IN2>){
  chomp;
  #print "$_";

  # remove previous exon/intron records
  #$_=~s/\s+exon\s+.*\d+..\d+.*\n\s+\/gene=\"\S+\"\n\s+\/number=\d+//g;
  $_=~s/     exon            (.|\n)+//g;
  $_=~s/     intron          (.|\n)+//g;
  #print "$_";

  my $add='';
  if(/\/gene=\"(\S+)\"/){
    my $gene=$1;
    if(/\s+(CDS|tRNA|rRNA).+?(\d+)\.\./){
      $gene .="_$2";
      #print "$gene\n";

      print STDERR "$gene\n" if (! exists $exon_loci{$gene});

      @{$exon_loci{$gene}} = sort {$a -> [0] <=> $b -> [0]} @{$exon_loci{$gene}};
      for (my $i=0; $i<@{$exon_loci{$gene}}; $i++){

        if($i>=1 && ($gene !~/rps12\_\d+/)){
          $add .="     intron          ";
          my $intron_start=$exon_loci{$gene}[$i-1]->[1]+1;
          my $intron_end=$exon_loci{$gene}[$i]->[0]-1;
          if ($exon_loci{$gene}[$i]->[2] eq "+"){
            $add .="$intron_start..$intron_end\n";
          }else{
            $add .="complement\($intron_start..$intron_end\)\n";
          }
          $add .="                     \/gene=\"$1\"\n" if ($gene=~/(\S+)\_\d+/);
        }

        $add .="     exon            ";
        if ($exon_loci{$gene}[$i]->[2] eq "+"){
          $add .="$exon_loci{$gene}[$i]->[0]..$exon_loci{$gene}[$i]->[1]\n";
        }else{
          $add .="complement\($exon_loci{$gene}[$i]->[0]..$exon_loci{$gene}[$i]->[1]\)\n";
        }

        #print STDERR "$gene\n";
        $add .="                     \/gene=\"$1\"\n" if ($gene=~/(\S+)\_\d+/);
      }
    }
  }
  #$add .="     gene";

  #print STDERR "$_\n";
  # a little confused!
  if(/ORIGIN\s+/){
    $add .="ORIGIN";
    $_=~s/ORIGIN/$add/g;
  }elsif($_!~/ORIGIN\s+/){
    $_.="$add     gene";
  }
  print "$_";
}
close IN2;
