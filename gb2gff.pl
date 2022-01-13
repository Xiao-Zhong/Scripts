#!/usr/bin/perl -w
use strict;

my $ingb=shift;
my $anno_version=shift;
my $genome_version=shift;

$anno_version ||="Test";
$genome_version ||="AP000423.1";

my $num = 1;
$/="\/";
open IN, "$ingb" || die "$!\n";
while(<IN>){
	#chomp;

#	unless($genome_version){
#		$genome_version=$1 if(/VERSION\s+(\S+)/);
#	}

	if (/\s+CDS\s+\S+\.\.|\s+tRNA\s+\S+\.\.|\s+rRNA\s+\S+\.\./){
		#print "$_\n";

		my $s=(/complement/) ? ("-") : ("+");
		#print "$s\n";

		s/\<|\>//g;
		my @info=split(/\,/);
		my @positions;
		for(my $i=0; $i<@info; $i++){
			if ($info[$i]=~/(\d+)\.\.(\d+)/){
				#print "\t$1_$2";
				push @positions, $1;
				push @positions, $2;
			}
		}

		@positions = sort {$a <=> $b } @positions;

    my $gid;
		my $n_line=<IN>;
		#print "##$n_line";
		if ($n_line=~/gene=\"(.+)\"/){
			my $gene = $1;
			$gene =~ s/\s+/\_/g;
			$gene =~ s/\;//g;
			$gid = "$gene\_$positions[0]\_$num";
		}else{
			$gid = "$genome_version\_$num";
		}
		$num++;

		print "$genome_version\t$anno_version\tgene\t$positions[0]\t$positions[-1]\t\.\t$s\t\.\tID=$gid;\n";
		for (my $i=0; $i<@positions-1; $i +=2){
			print "$genome_version\t$anno_version\texon\t$positions[$i]\t$positions[$i+1]\t\.\t$s\t\.\tParent=$gid;\n";
		}
	}
}
close IN;
#$/="\n";
