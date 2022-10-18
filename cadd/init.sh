#!/bin/bash

set -e
set -x

SCRIPT_DIR=../scripts
source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh37/whole_genome_SNVs.tsv.gz"
GENOME=hg19
TEMP_FILE=whole_genome_SNVs.tsv.gz
OUTFILE=./$GENOME/cadd.vcf.gz
NAME=cadd

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	{
	echo '##fileformat=VCFv4.2';
	echo '##FORMAT=<ID=CADD_PH,Number=A,Type=Float,Description="This is the CADD PHRED score">';
	echo '#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO';
	zcat $TEMP_FILE | grep -v '#' | awk -v OFS='\t' ' { print $1, $2, ".", $3, $4, ".", "PASS", "CADD_PH="$5 } ';
	} | bgzip --threads $N_THREADS > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE
