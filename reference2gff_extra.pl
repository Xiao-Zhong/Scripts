#!/usr/bin/perl -w
use strict;

my $input=shift;

my $output;
my %cds;
open IN, "$input" || die "$!\n";
while(<IN>){
	chomp;
	my @info=split;
	if (/NC_000932.1/){

		#my @info=split;
		if ($info[2]=~/CDS/){
			if (/ID=(\S+);Parent=.+;gene=(\S+);product=/){
				#print "$1\t$2\n";
				push @{$cds{"$2_$1"}}, [@info];
			}
		}
	}else{
		#print "$info[0]\t$info[2]\n";
		if ($info[2]=~/(\d+)\.\.(\d+)/){
			#print "\t$1\t$2\n";
			my $start=$1;
			my $end=$2;
			my $s=($info[2]=~/complement/) ? ("-") : ("+");
		
			my $gid="rRNA_$info[0]_$start";

			$output .="NC_000932.1\tReference\tgene\t$start\t$end\t\.\t$s\t\.\tID=$gid;\n";
			$output .="NC_000932.1\tReference\texon\t$start\t$end\t\.\t$s\t\.\tParent=$gid;\n";
		}
	}
}
close IN;

foreach my $gid(keys %cds){
	#print "$gid\n";
	
	@{$cds{$gid}}=sort {$a->[3] <=> $b->[3]} @{$cds{$gid}};

	print "NC_000932.1\tReference\tgene\t$cds{$gid}[0][3]\t$cds{$gid}[-1][4]\t\.\t$cds{$gid}[0][6]\t\.\tID=$gid;\n";
	for (my $i=0; $i<@{$cds{$gid}}; $i++){
		print "NC_000932.1\tReference\texon\t$cds{$gid}[$i][3]\t$cds{$gid}[$i][4]\t\.\t$cds{$gid}[$i][6]\t\.\tParent=$gid;\n";
	}
	
}

print $output;
