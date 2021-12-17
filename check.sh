#!/bin/bash

if [ $# -lt 1 ];then
	echo "Usage: sh $0 <ID> <Version>"
	exit
fi

#less $1_$2.iff|sed 's/\//   /g'|sed 's/CDS/exon/g' |sed 's/rRNA/exon/g' |sed 's/tRNA/exon/g' > $1_$2.iff2
perl sff2gff.pl $1.sff metadata.txt >$1\_test.gff
perl getGene_edited.pl $1\_test.gff ~/project/database/$1.fa >$1\_test.cds
perl cds2aa_edited.pl -check $1\_test.cds >$1\_test.cds.check
perl Gene.overlap.edited.pl --num ~/project/database/$1.gff $1\_test.gff > $1\_gb_vs_test_overlap
perl Gene.overlap.edited.pl --num $1\_test.gff ~/project/database/$1.gff > $1\_test_vs_gb_overlap
#perl overlap_exon0.pl reference_$1_overlap  > reference_test_overlap.$1.type.stat
perl overlap_exon_boundaries.pl $1\_gb_vs_test_overlap >$1\_gb_vs_test_overlap.stat
perl overlap_exon_boundaries.pl $1\_test_vs_gb_overlap >$1\_test_vs_gb_overlap.stat
