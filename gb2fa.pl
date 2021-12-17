#!/usr/bin/perl -w
use strict;

my $infile=shift;
my $linelen=shift;

$linelen ||=80;

$/ = 'ORIGIN';
open IN, "$infile" || die "$!\n";
#my $test1 = <IN>;
my $head = <IN>;
my $id = $1 if ($head =~ /LOCUS\s+(\S+)/);

my $seq = <IN>;
$seq =~ s/[^a-zA-Z]//g;
$seq = uc($seq);

#print ">$id\n$seq\n";
close IN;

print ">$id\n";
for(my $i=0; $i<length($seq); $i +=$linelen) {
	my $seq2=substr($seq, $i, $linelen);#."\n";
	print "$seq2\n";
}
