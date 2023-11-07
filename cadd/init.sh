#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh37/whole_genome_SNVs.tsv.gz"
GENOME=hg19
TEMP_FILE=whole_genome_SNVs.tsv.gz
OUTFILE=./$GENOME/cadd.vcf.gz
NAME=CADD

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	{
	echo '##fileformat=VCFv4.2';
	echo '##INFO=<ID=CADD_PH,Number=A,Type=Float,Description="This is the CADD PHRED score">';
	echo '##INFO=<ID=CADD_RAW,Number=A,Type=Float,Description="This is the raw CADD score">';
	echo '#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO';
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1, $2, ".", $3, $4, ".", "PASS", "CADD_PH="$6";CADD_RAW="$5 } ';
	} | bgzip --threads $N_THREADS > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE
