#!/usr/bin/perl -w
use strict;

my $intxt=shift;
my $anno_version=shift;
my $genome_version=shift;

$anno_version ||="Test";
$genome_version ||="AP000423.1";

my %gene_hash;
open IN, "$intxt" || die "$1\n";
while(<IN>){
	chomp;
	my @info=split;
	#print "$info[0]\n";

	my $start=$info[4];
	my $end=$info[4]+$info[5]-1;
	if($info[3] eq '-'){
		$start=154478-$start;
		$end=154478-$end;
	}

	($start, $end)=($start > $end) ? ($end, $start) : ($start, $end);

	#print "$info[0]\t$info[1]\t$info[2]\t$info[3]\t$start\t$end\t$info[5]\n";
	# keys: gene	exon/intron	strands
	push @{$gene_hash{$info[0]}{$info[1]}{$info[3]}}, [$start, $end, $info[5]];
	#push @{$gene_hash{$info[0]}{intron}{"$info[3]"}}, [$info[0], $info[1], $start, $end, $info[5]] if ($info[1] eq 'intron');
}
close IN;

foreach my $gid(sort keys %gene_hash){
	#print "$gid\n";
	foreach my $f(sort keys %{$gene_hash{$gid}}){
		#print "$gid\t$f\n";
		foreach my $s(sort keys %{$gene_hash{$gid}{$f}}){
			#print "$gid\t$f\t$s\n";

			if ($s eq "+"){
				@{$gene_hash{$gid}{$f}{$s}} = sort {$a -> [0] <=> $b -> [0]} @{$gene_hash{$gid}{$f}{$s}};
			}else{
				@{$gene_hash{$gid}{$f}{$s}} = reverse (sort {$a -> [0] <=> $b -> [0]} @{$gene_hash{$gid}{$f}{$s}});
			}

			for(my $i=0; $i<@{$gene_hash{$gid}{$f}{$s}}; $i++){
				print "$gid\t$f\t$i\t$s";
				print "\t$gene_hash{$gid}{$f}{$s}[$i]->[0]";
				print "\t$gene_hash{$gid}{$f}{$s}[$i]->[1]";
				print "\t$gene_hash{$gid}{$f}{$s}[$i]->[2]";
				print "\n";
			}
		}
	}
}




=c1
#$/="\/";
open IN, "$ingb" || die "$!\n";
while(<IN>){
	chomp;

#	unless($genome_version){
#		$genome_version=$1 if(/VERSION\s+(\S+)/);
#	}

	if (/\s+CDS\s+|\s+tRNA\s+|\s+rRNA\s+/){
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

		my $n_line=<IN>;
		$n_line=~/gene=\"(\S+)\"/;
		my $gid="$1\_$positions[0]";

		print "$genome_version\t$anno_version\tgene\t$positions[0]\t$positions[-1]\t\.\t$s\t\.\tID=$gid;\n";
		for (my $i=0; $i<@positions-1; $i +=2){
			print "$genome_version\t$anno_version\texon\t$positions[$i]\t$positions[$i+1]\t\.\t$s\t\.\tParent=$gid;\n";
		}
	}
}
close IN;
#$/="\n";
