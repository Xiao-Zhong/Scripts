#!/usr/bin/perl -w
use strict;

my $infa=shift;
my $ingff=shift;
my $inintron=shift;
my $half=shift;

$half ||=50; 
my $species=$1 if ($infa=~/(\S+).fa/);

my %gene_group;
open IN, "$inintron" || die "$!\n";
#$/="GROUP IIA";<IN>;$/="GROUP IIB";
while(<IN>){
	chomp;
	#print "$_\n";
	
	if (/- \S+?\_(\S+)/){
		#print "$1\n";
		$gene_group{$1}++;
	}
}
close IN;

my $seq;
open IN, "$infa" || die "$!\n";
$/=">";<IN>;$/="\n";
while(<IN>){
	my $scaf=$1 if(/^(\S+)/);
    	$/='>';
	$seq=<IN>;
    	chomp($seq);
    	$seq=~s/\s+//g;
    	$seq=~tr/atcg/ATCG/;
    	$/="\n";
    	#$seq{$scaf}=$seq;
}
close IN;

my %gff; my %strand;
open IN, "$ingff" || die "$!\n";
while(<IN>){
    	chomp;
    	my @info=split;
    	if($info[8]=~/^Parent=(\S+?);/){
        	push @{$gff{$1}}, ($info[3], $info[4]);
		$strand{$1}=$info[6];
    	}
}
close IN;

#foreach my $gene(keys %gene_group){
	#print "$gene\n";	

open OUT, ">$ingff.group1.intron5.$half.fa" || die "$!\n";
open OUT2, ">$ingff.group1.intron3.$half.fa" || die "$!\n";
foreach my $gid(keys %gff){
	#print "$gid";
	
	next if ($gid =~ /rps12/);
	#next if ($gid =~ /rRNA/);
	#next if ($gid =~ /tRNA/);

	#my $gene=$1 if($gid=~/(\S+?)\_/);
	#print "$gene\n";
	next unless (exists $gene_group{$gid});

	@{$gff{$gid}} = sort {$a <=> $b} @{$gff{$gid}};
	@{$gff{$gid}} = reverse @{$gff{$gid}} if ($strand{$gid} eq '-');

	for(my $i=1; $i<@{$gff{$gid}}-1; $i++){
		my $type;
		#if ($i==0){
		#	$type="translation_head";
		#}elsif($i==@{$gff{$gid}}-1){
		#	$type="translation_tail";
		#}elsif($i % 2  == 1){
		#	$type="5-intron";
		#}else{
		#	$type="3-intron";
		#}

		#my $output_head =">$gid\_$gff{$gid}[$i]\_$strand{$gid}";

		my $block_s=$gff{$gid}[$i]-$half;
		my $block_seq=substr($seq, $block_s-1, $half+1+$half);
		#print "$block_seq\n";	
		if ($strand{$gid} eq '-'){
			$block_seq=~ tr/AGCTagct/TCGAtcga/;
			$block_seq= reverse  $block_seq;	
		}
		#my $output_head="$block_seq";

		if ($i==0){
			$type="translation_head";
		}elsif($i==@{$gff{$gid}}-1){
			$type="translation_tail";
		}elsif($i % 2  == 1){
			$type="5-intron";
			print OUT ">$species\_$gid\_$gff{$gid}[$i]\_$strand{$gid}\_$type\n$block_seq\n";
		}else{
			$type="3-intron";
			print OUT2 ">$species\_$gid\_$gff{$gid}[$i]\_$strand{$gid}\_$type\n$block_seq\n";
		}			
	}
	#print "\n";
}
#}
