#!/usr/bin/perl -w
use strict;

my $infa=shift;
my $inlist=shift;
#my $label=shift;

open IN, "$infa" || die "$!\n";
my %genome;
my $scaf;
my %fa_len;
$/=">";<IN>;$/="\n";
while(<IN>){
	$scaf=$1 if (/^(\S+)/);
	$/=">";
	my $seq=<IN>;
	chomp($seq);
	$seq=~s/\s+//g;
	$seq=~tr/atcg/ATCG/;
        $/="\n";
	$genome{$scaf}=$seq;
	$fa_len{$scaf}=length($seq);
}
close IN;

my %list;
my $gene='';
my $num=0;
my %nchash;
open IN2, "$inlist" || die "$!\n";
while(<IN2>){
	chomp;
	my @info=split;
	#if ($info[2] ne $gene){
	#	$gene=$info[2];
	#	$num++;
	#}
	
	push @{$list{$1}}, [@info] if ($info[2]=~/exon/ &&  $info[8]=~/=(\S+?);/ && ($info[8]!~/=rps12/));
}
close IN2;

print "##gff-version 3\n";
print "##sequence-region $scaf 1 $fa_len{$scaf}\n";
foreach my $gid(sort keys %list){
	#print STDERR "$gid\n";
	my $type;
	if ($list{$gid}[0][8]=~/tRNA/){
		$type="tRNA";
	}elsif($list{$gid}[0][8]=~/rRNA/){
		$type="rRNA";
	}else{
		$type="mRNA";
	}
	
	@{$list{$gid}}=sort {$a->[3] <=> $b->[3]} @{$list{$gid}};
	print "$scaf\tstandard\tgene\t$list{$gid}[0][3]\t$list{$gid}[-1][4]\t.\t$list{$gid}[0][6]\t\.\tID=$gid;Name=$gid;gene=$gid;\n";
	
	print "$scaf\tstandard\tmRNA\t$list{$gid}[0][3]\t$list{$gid}[-1][4]\t.\t$list{$gid}[0][6]\t\.\tID=$gid\-mRNA;Parent=$gid;gene=$gid;\n" if ($type=~/mRNA/);
	print "$scaf\tstandard\ttRNA\t$list{$gid}[0][3]\t$list{$gid}[-1][4]\t.\t$list{$gid}[0][6]\t\.\tID=$gid\-tRNA;Parent=$gid;gene=$gid;\n" if ($type=~/tRNA/);
	#print "$scaf\tdogma\ttRNA\t$list{$gid}[0][0]\t$list{$gid}[-1][1]\t100\t$list{$gid}[0][3]\t\.\tID=$gid\-tRNA;Parent=$gid;Name=$list{$gid}[0][2];\n" if ($type=~/tRNA/);
	print "$scaf\tstandard\trRNA\t$list{$gid}[0][3]\t$list{$gid}[-1][4]\t.\t$list{$gid}[0][6]\t\.\tID=$gid\-rRNA;Parent=$gid;gene=$gid;\n" if ($type=~/rRNA/);
	#print "$scaf\tdogma\trRNA\t$list{$gid}[0][0]\t$list{$gid}[-1][1]\t100\t$list{$gid}[0][3]\t\.\tID=$gid\-rRNA;Parent=$gid;Name=$list{$gid}[0][2];\n" if ($type=~/rRNA/);

	for (my $i=0; $i<@{$list{$gid}}; $i++){
		#print "$scaf\tstandard\texon\t$list{$gid}[$i][3]\t$list{$gid}[$i][4]\t100\t$list{$gid}[0][6]\t\.\tID=$gid-mRNA:exon:$i;Parent=$gid-mRNA;Name=$gid exon;\n" if ($type=~/mRNA/);
		print "$scaf\tstandard\texon\t$list{$gid}[$i][3]\t$list{$gid}[$i][4]\t.\t$list{$gid}[0][6]\t\.\tID=$gid-exon$i;Parent=$gid-tRNA;gene=$gid;\n" if ($type=~/tRNA/);
		print "$scaf\tstandard\texon\t$list{$gid}[$i][3]\t$list{$gid}[$i][4]\t.\t$list{$gid}[0][6]\t\.\tID=$gid-exon$i;Parent=$gid-rRNA;gene=$gid;\n" if ($type=~/rRNA/);
		#print "$scaf\tdogma\texon\t$list{$gid}[$i][0]\t$list{$gid}[$i][1]\t100\t$list{$gid}[0][3]\t\.\tID=$gid-tRNA:exon:$i;Parent=$gid-tRNA;\n" if ($type=~/tRNA/);
		#print "$scaf\tdogma\texon\t$list{$gid}[$i][0]\t$list{$gid}[$i][1]\t100\t$list{$gid}[0][3]\t\.\tID=$gid-rRNA_primary_transcript:exon:$i;Parent=$gid-rRNA_primary_transcript;Name=$list{$gid}[0][2]-dogma;\n" if ($type=~/rRNA/);
		#print "$scaf\tdogma\texon\t$list{$gid}[$i][0]\t$list{$gid}[$i][1]\t100\t$list{$gid}[0][3]\t\.\tID=$gid-rRNA:exon:$i;Parent=$gid-rRNA;\n" if ($type=~/rRNA/);		

		print "$scaf\tstandard\tCDS\t$list{$gid}[$i][3]\t$list{$gid}[$i][4]\t.\t$list{$gid}[0][6]\t\.\tID=$gid-cds$i;Parent=$gid-mRNA;gene=$gid;\n" if ($type=~/mRNA/);
	}	
}

=cut
print "##FASTA\n";
foreach my $name(keys %genome){
	my $seq=$genome{$name};

	print ">$name\n";
        my $len=length($seq);
	for(my $i=0; $i<$len; $i +=60) {
		my $seq2=substr($seq,$i,60);#."\n";
		print "$seq2\n";
	}
}

