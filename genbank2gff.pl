#!/usr/bin/perl -w
use strict;

my $infile=shift;

my %CDS;
my %gid;
open IN, "$infile" || die "$!\n";
while(<IN>){
	chomp;
	next unless ($_);
	next if (/^#/);

	my @info=split(/\t/, $_);

	my $key;
	if ($info[2]=~/CDS/){
		$key="$1\_$2" if ($info[8]=~/ID=(\S+?);.+;gene=(\S+?);/);
		push @{$CDS{$key}}, [@info];
	}
	if ($info[2]=~/exon/){
		$key="$1\_$2" if ($info[8]=~/Parent=(\S+?);.+;gene=(\S+?);/ || $info[8]=~/Parent=(\S+?);.+;product=(\S+)/);
		push @{$CDS{$key}}, [@info];
	}
}
close IN;

foreach my $id (sort keys %CDS){
	#print "$id\n";

	my $newc='';
	if ($CDS{$id}[0][6] eq '+'){
		@{$CDS{$id}}=sort {$a->[3] <=> $b->[3]} @{$CDS{$id}};
		#$CDS{$id}[-1][4] +=3;
		print "$CDS{$id}[0][0]\t$CDS{$id}[0][1]\tgene\t$CDS{$id}[0][3]\t $CDS{$id}[-1][4]\t\.\t$CDS{$id}[0][6]\t\.\tID=$id;\n";
		for (my $i=0; $i<@{$CDS{$id}}; $i++){
			$CDS{$id}[$i][2]="exon";
			$CDS{$id}[$i][8]="Parent=$id;";
			$newc=join "\t", @{$CDS{$id}[$i]};
			print "$newc\n";
		}
	}
	if ($CDS{$id}[0][6] eq '-'){
		@{$CDS{$id}}=reverse (sort {$a->[3] <=> $b->[3]} @{$CDS{$id}});
		#$CDS{$id}[-1][3] -=3;
		print "$CDS{$id}[0][0]\t$CDS{$id}[0][1]\tgene\t$CDS{$id}[-1][3]\t $CDS{$id}[0][4]\t\.\t$CDS{$id}[0][6]\t\.\tID=$id;\n";
		for (my $i=0; $i<@{$CDS{$id}}; $i++){
			$CDS{$id}[$i][2]="exon";
			$CDS{$id}[$i][8]="Parent=$id;";
			$newc=join "\t", @{$CDS{$id}[$i]};
			print "$newc\n";
		}
	}
}
