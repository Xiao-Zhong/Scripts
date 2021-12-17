#!/usr/bin/perl -w
use strict;

my $in_test_gff=shift;
my $in_reference_gff=shift;
my $in_check=shift;
my $in_fa=shift;

open IN, "$in_fa" || die "$!\n";
my $fa;
$/=">";<IN>;$/="\n";
while(<IN>){
	my $scaf=$1 if (/^(\S+)/);
	$/=">";
	my $seq=<IN>;
	chomp($seq);
	$seq=~s/\s+//g;
	$seq=~tr/atcg/ATCG/;
        $/="\n";
	$fa=$seq;
}
close IN;

my %tgff;
open IN, "$in_test_gff" || die "$!\n";
while(<IN>){
	chomp;
	my @info=split;
	if ($info[2]=~/gene/){
		if ($info[8]=~/=(\S+);/){
			#print "$1\n";
			push @{$tgff{$1}}, @info; 
		}
	}
}
close IN;

my %rgff;
open IN, "$in_reference_gff" || die "$!\n";
while(<IN>){
	chomp;
	my @info=split;
	if ($info[2]=~/gene/){
		if ($info[8]=~/=(\S+?);/){
			#print "$1_$info[3]\n";
			push @{$rgff{$1}}, @info; 
		}
	}
}
close IN;

open IN, "$in_check" || die "$!\n";
while(<IN>){
	chomp;
	next if (/^rps19_154278/);
	my @info=split;
	print "$info[0]\t$tgff{$info[0]}[3]\t$tgff{$info[0]}[4]\t$tgff{$info[0]}[6]";
	my $tstart=$tgff{$info[0]}[3];
	my $tend=$tgff{$info[0]}[4];
	my $tstrand=$tgff{$info[0]}[6]; #print "$tstrand\t";

	my $gene=$1 if ($info[0]=~/(\S+?)\_/);
	print "\t$gene";
	
	foreach my $rid(keys %rgff){
		if ($rid=~/$gene/){
			print "\t$rid\t$rgff{$rid}[3]\t$rgff{$rid}[4]\t$rgff{$rid}[6]";
			my $rstart=$rgff{$rid}[3];
			my $rend=$rgff{$rid}[4];
			my $rstrand=$rgff{$rid}[6]; #print "$rstrand\t";

			if ($tstrand eq $tstrand){
				#print "\ton_the_same_strand";
				
				my $start_dis; my $seq;my $reminder;
				if ($tstrand eq "+"){
					if ($tend < $rstart){
						#print "\tupstream_&_no_overlap";
						$start_dis=$rstart-$tstart;
						$reminder=$start_dis%3;
						print "\t$start_dis\t$reminder";
						
						$seq=substr($fa, $tstart-1, $start_dis+3);
						print "\t$seq";
			
					}	
				}else{
					if ($tstart > $rend){
						#print "\tupstream_&_no_overlap";
						$start_dis=$tend-$rend;
						$reminder=$start_dis%3;
						print "\t$start_dis\t$reminder";
			
						$seq=substr($fa, $rend-2-1, $start_dis+3);
						$seq=~ tr/AGCTagct/TCGAtcga/;
						$seq= reverse  $seq;
						print "\t$seq";	
					}
				}
				
				
				if($seq){
					my @positions;
					print "\t";
					while ($seq=~/ATG/g){
						my $a=$-[0]+1;
						#print "\t$a\_$+[0]";
						push @positions, [$a, $+[0]];
					}				
					
					for(my $i=0; $i<@positions; $i++){
						print "$positions[$i][0]..$positions[$i][1];";
					}

					print " ";
					for(my $i=1; $i<@positions-1; $i++){
						my $internal_dist=$positions[-1][0]-$positions[$i][0];
						my $internal_reminder=$internal_dist%3;
						print "$internal_dist|$internal_reminder;";
					}
				}
			}

		}
	}
	print "\n";
	
	#print "\t$rgff{$info[0]}[3]\t$rgff{$info[0]}[4]\t$rgff{$info[0]}[6]\t$rgff{$info[0]}[8]\n";
}
close IN;







