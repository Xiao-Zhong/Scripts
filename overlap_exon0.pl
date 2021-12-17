#!/usr/bin/perl -w
use strict;

my $inoverlap=shift;

my %type_hash;
open IN, "$inoverlap" || die "$!\n";
while(<IN>){
	chomp;
	#next if (/RNA/);
	my @info=split;
	my $gene=($info[0]=~/RNA/) ? ("RNA") : ("CDS");
	
	if (@info>4){
		#print "$info[0]\t$info[1]\t$info[2]\t$info[3]";
		for(my $i=4; $i<@info; $i++){
			if ($info[$i]=~/(\S+)_\d+\((\d+),(\d+),\d+;\S+;(\d+),(\d+),(\d+)\)(\S+)/){
				if ($6 !=0){
					#print "\t$info[$i]";
					$type_hash{$gene}{$7}++;
				}
			}
		}
	}else{
		#print "$_\n";
		$type_hash{"no_overlaps"}{"$_"}++;
	}
}
close IN;

foreach my $gene(keys %type_hash){
	print "$gene:\n";
	foreach my $overlap(keys %{$type_hash{$gene}}){
		print "$overlap\t$type_hash{$gene}{$overlap}\n";
	}
	print "\n";
}
