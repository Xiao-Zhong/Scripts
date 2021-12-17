#!/usr/bin/perl -w
use strict;

my $intable=shift;

open IN, "$intable" || die "$!\n";
while(<IN>){
	chomp;
	next if (/^SequenceName/);
	my @info=split;

	my @positions;
	push @positions, $info[1];
	push @positions, $info[2];
	push @positions, $info[5] if (/Intron/);
	push @positions, $info[6] if (/Intron/);
	
	my $strand=($info[1]<$info[2]) ? ("+") : ("-");
	
	@positions = sort {$a <=> $b } @positions;
	$positions[1] -=1 if (@positions > 2);
	$positions[2] +=1 if (@positions > 2);
	
	my $gid="tRNA_$info[3]_$positions[0]";

	print "NC_000932.1\tReference\tgene\t$positions[0]\t$positions[-1]\t\.\t$strand\t\.\tID=$gid;\n";
	for (my $i=0; $i<@positions; $i +=2){
		print "NC_000932.1\tReference\texon\t$positions[$i]\t$positions[$i+1]\t\.\t$strand\t\.\tParent=$gid;\n";
	}
}
close IN;
