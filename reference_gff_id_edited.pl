#!/usr/bin/perl -w
use strict;

my $ingff=shift;

my $gid;
open IN, "$ingff"|| die "$!\n";
while(<IN>){
	chomp;
	my @info=split;
	if ($info[8]=~/=tRNA_|=rRNA_/){
		print "$_\n";
	}else{
		#my $gid='';
		if ($info[2]=~/gene/){
			$info[8]=~/ID=(\S+?)\_/;
			$gid="$1\_$info[3]";

			$info[8]="ID=$gid;";
		}else{
			#print "$gid\n";
			$info[8]="Parent=$gid;";
		}
		print join "\t", @info, "\n";
	}
}
close IN;
