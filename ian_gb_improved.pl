#!/usr/bin/perl -w
use strict;

my $ingb=shift;

open IN, "$ingb" || die "$!\n";
while(<IN>){
	chomp;
	if(/complement/){
		#print "$_";
		my @info=split(/\,/);
		#if ($info[0]=~/(\d+)\.\.(\d+)/){
		#	print "\t$1\t$2\n";
		#}
		
		my @positions;
		for(my $i=0; $i<@info; $i++){
			if ($info[$i]=~/(\d+)\.\.(\d+)/){
				#print "\t$1_$2";
				push @positions, $1;
				push @positions, $2;
			}
		}

		@positions = sort {$a <=> $b } @positions;
		
		my @info2=split;
		print "     ";
		printf "%-16s", $info2[0];
		if(@positions==2){
			print "complement($positions[0]..$positions[1])";
		}else{
			#print "complement(join(";
			my $tmp="complement(join(";
			for(my $i=0; $i<@positions; $i +=2){
				#print "$positions[$i]..$positions[$i+1],";
				$tmp .="$positions[$i]..$positions[$i+1],";
			}
			#print "))";
			$tmp =~ s/.$//g;
			$tmp .="))";
			print "$tmp";
		}
		print "\n";
	}else{
		print "$_\n";
	}
}
close IN;
