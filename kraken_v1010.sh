#!/bin/bash

SOFTWARE=/genomics/software
KRAKEN2=$SOFTWARE/kraken2/kraken2/kraken2
KRONA=/usr/local/bin/ktImportTaxonomy

DB=/genomics/software/kraken2/database_std

THREADS=30
LOG=kraken2-`date '+%s'`.log

INPUTDIR="fastqs-trimmed"

OUTPUTDIR="fastqs-trimmed-kraken2"
mkdir -p $OUTPUTDIR

for i in $INPUTDIR/*_R1_001.fastq.gz; do
	R1=`basename $i`
	R2=${R1%R1_001.fastq.gz}R2_001.fastq.gz
	OUT=$OUTPUTDIR/${R1%_R1_*.fastq.gz}
	echo "$R1 $R2 $OUT"

	#kraken2
	$KRAKEN2 --threads $THREADS \
	  	--db $DB \
        	--paired $INPUTDIR/$R1 $INPUTDIR/$R2 \
		--report $OUT\_report.txt \
        	--output $OUT\_output.txt \
		>$OUT\.log 2>$OUT\.err

	#krona
	cat $OUT\_output.txt | cut -f 2,3 > $OUT\_output.krona
	$KRONA -o $OUT\_output.krona.html $OUT\_output.krona

	echo "$OUT: the job is done!"
done

