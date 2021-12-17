#!/usr/bin/perl -w
use strict;

my $inoverlap=shift;

open IN, "$inoverlap" || die "$!\n";
while(<IN>){
	chomp;
	next if (/RNA/);
	my @info=split;
	#print "$info[0]\t$#info\n";
	
	next if ($#info < 4);
	#print "$_\n";

	my $gene1=$1 if (/^(\S+?)\_/);
	for(my $i=4; $i<@info; $i++){
		if ($info[$i]=~/(\S+)_\d+\((\d+),(\d+),\d+;\S+;(\d+),(\d+),\d+\)/){
			if ($gene1 eq "$1"){
				if ($2 != $3 or $4 != $5){
					print "$_\n";
				}
			}			
		}	
	}
}
close IN;
