#!/usr/bin/perl -w
use strict;

my $in_gbff = shift;

#my $num = 0;
open IN, "$in_gbff" || die "$!\n";
$/ = "LOCUS";
while(<IN>){
  #$num++;
  my $single = $_;
  #chomp($single);
  #print "$single\n";

  $single =~ s/LOCUS$//g;
  if ($single =~ /ACCESSION\s+(\S+)/){
    #print "$1\n";
    open OUT, ">$1\.gbff" || die "$!\n";
    print OUT "LOCUS";
    print OUT "$single";
    close OUT;
  }

}
close IN;

#print "$num\n";
