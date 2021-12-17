#!/usr/bin/perl -w
use strict;

my $infile=shift;

my %CDS;
my %gid;
open IN, "$infile" || die "$!\n";
while(<IN>){
	chomp;
	next unless ($_);
	if(/NC_001666.2/){
		#print "$_\n";
		my $gid;
		if (/gene=(\S+?)].+protein_id=(\S+?)]/){
			#print "$1\t$2";
			$gid="$1_$2";
		}
		
		my @info=split(/\=/);
		#print "\t$info[4]";
		my $strand=($info[4]=~/^complement/) ? ("-") : ("+");
		
		my @info2=split(/\,/, $info[4]);
		my @positions;
		for(my $i=0; $i<@info2; $i++){
			#print "\t$info2[$i]";
			if($info2[$i]=~/(\d+)\.\.(\d+)/){
				#print "\t$1\t$2";
				push @positions, $1;
				push @positions, $2;
			}
		}
		@positions = sort {$a <=> $b } @positions;
		#print "\t$positions[0]_$positions[-1]";
		#print "\n";


		print "NC_001666.2\tReference\tgene\t$positions[0]\t$positions[-1]\t\.\t$strand\t\.\tID=$gid;\n";
		for (my $i=0; $i<@positions; $i +=2){
			print "NC_001666.2\tReference\texon\t$positions[$i]\t$positions[$i+1]\t\.\t$strand\t\.\tParent=$gid;\n";
		}

		
	}


}
close IN;

=cut
foreach my $id (sort keys %CDS){
	#print "$id\n";

	my $newc='';
	if ($CDS{$id}[0][6] eq '+'){
		@{$CDS{$id}}=sort {$a->[3] <=> $b->[3]} @{$CDS{$id}};
		#$CDS{$id}[-1][4] +=3;
		print "$CDS{$id}[0][0]\t$CDS{$id}[0][1]\tmRNA\t$CDS{$id}[0][3]\t $CDS{$id}[-1][4]\t\.\t$CDS{$id}[0][6]\t\.\tID=$id;\n";
		for (my $i=0; $i<@{$CDS{$id}}; $i++){
			$CDS{$id}[$i][8]="Parent=$id;";
			$newc=join "\t", @{$CDS{$id}[$i]};
			print "$newc\n";
		}
	}
	if ($CDS{$id}[0][6] eq '-'){
		@{$CDS{$id}}=reverse (sort {$a->[3] <=> $b->[3]} @{$CDS{$id}});
		#$CDS{$id}[-1][3] -=3;
		print "$CDS{$id}[0][0]\t$CDS{$id}[0][1]\tmRNA\t$CDS{$id}[-1][3]\t $CDS{$id}[0][4]\t\.\t$CDS{$id}[0][6]\t\.\tID=$id;\n";
		for (my $i=0; $i<@{$CDS{$id}}; $i++){
			$CDS{$id}[$i][8]="Parent=$id;";
			$newc=join "\t", @{$CDS{$id}[$i]};
			print "$newc\n";
		}
	}
}
