#!/usr/bin/perl -w
use strict;

my $in_overlap=shift;

print "#gene\tCDS_length_of_A\tCDS_length_of_B\toverlap_length\toverlap_rate_of_A(%)\toverlap_rate_of_B(%)\n";
my $total = 0;
my $recovered = 0;
open IN, "$in_overlap" || die "$!\n";
while(<IN>){
  chomp;

  $total++;

  my @info=split;
  my $reference_id=$1 if($info[0]=~/(\S+?)\_\d+/);

  my $same;
  my @output;
  stop: for(my $i=4; $i<@info; $i++){
    #$same=1 if($info[$i]=~/$reference_id\_\d+\S+\=\=\=\=/);
    if ($info[$i] =~ /\;(\d+)\,(\d+)\,(\d+)\)/){
      #print "\t$1\t$2\t$3";

      if ($1 == $2){
        $same = "same";
        last stop;
      }else{
        #print "$info[0]\t$1\_$2\_$3";
        # printf  "\_%.2f", $3/$1*100;
        # printf  "\_%.2f", $3/$2*100;
        push @output, [$1, $2, $3];
      }
    }
  }

  if(!$same){
    #print "$info[0]";
    for(my $i=0; $i<@output; $i++){
      print "$info[0]";
      #print "$output[$i][1]\n";
      print "\t$output[$i][0]\t$output[$i][1]\t$output[$i][2]";
      printf  "\t%.2f", $output[$i][2]/$output[$i][0]*100;
      printf  "\t%.2f", $output[$i][2]/$output[$i][1]*100;
      print "\n";
    }
    #print "\n";
  }else{
    $recovered++;
  }
}
close IN;

print "\n";
print "#total_genes:\t$total\n";
print "#genes_with_recovered_completely:\t$recovered\n";
print "#percentage(%):";
printf "\t%.2f\n", $recovered/$total*100;
