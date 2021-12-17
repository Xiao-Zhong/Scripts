#!/usr/bin/perl -w
use strict;

my $infile=shift;

my $gene_start; my $gene_label='';
my %CDS;
open IN, "$infile" || die "$!\n";
while(<IN>){
	chomp;
	my @info=split(/\s+/, $_);
	$info[0]="NC_000932.1";

	#($c[3],$c[4])=($c[4],$c[3]) if($c[3]>$c[4]);
	my $tmp=$info[2];
	if ($info[2]>$info[3]){
		$info[2]=$info[3];
		$info[3]=$tmp;
	}
	#print "$info[1]\t$info[2]\t$info[3]\t$tmp\n";

	if ($info[1] ne  "$gene_label"){
		$gene_label=$info[1];
		$gene_start=$info[2];
	}
	
	push @{$CDS{"$info[1]\_$gene_start"}}, [@info];
	
}
close IN;

foreach my $id (sort keys %CDS){
	#print "$gid\n";

	my $newc='';
	if ($CDS{$id}[0][4] eq '+'){
		@{$CDS{$id}}=sort {$a->[2] <=> $b->[2]} @{$CDS{$id}};
		print "$CDS{$id}[0][0]\tTEST\tgene\t$CDS{$id}[0][2]\t $CDS{$id}[-1][3]\t\.\t$CDS{$id}[0][4]\t\.\tID=$id;\n";
		for (my $i=0; $i<@{$CDS{$id}}; $i++){
			print "$CDS{$id}[0][0]\tTEST\texon\t$CDS{$id}[$i][2]\t $CDS{$id}[$i][3]\t\.\t$CDS{$id}[0][4]\t\.\tParent=$id;\n";
		}
	}
	if ($CDS{$id}[0][4] eq '-'){
		@{$CDS{$id}}=reverse (sort {$a->[2] <=> $b->[2]} @{$CDS{$id}});
		print "$CDS{$id}[0][0]\tTEST\tgene\t$CDS{$id}[-1][2]\t $CDS{$id}[0][3]\t\.\t$CDS{$id}[0][4]\t\.\tID=$id;\n";
		for (my $i=0; $i<@{$CDS{$id}}; $i++){
			print "$CDS{$id}[0][0]\tTEST\texon\t$CDS{$id}[$i][2]\t $CDS{$id}[$i][3]\t\.\t$CDS{$id}[0][4]\t\.\tParent=$id;\n";
		}
	}
}
