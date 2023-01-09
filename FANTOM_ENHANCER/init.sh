#!/bin/bash

set -e
set -x

SCRIPT_DIR=../../scripts
source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download A tab-delimited file containing OMIM's Synopsis of the Human Gene Map including additional information such as genomic coordinates and inheritance
URL="https://fantom.gsc.riken.jp/5/datafiles/latest/extra/Enhancers/human_permissive_enhancers_phase_1_and_2.bed.gz"
GENOME=hg19
TEMP_FILE=human_permissive_enhancers_phase_1_and_2.bed.gz
OUTFILE=./$GENOME/FantomEnhancer.bed.gz
NAME=FANTOM_ENHANCER

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	{
	echo '##fileformat=bed';
	echo '##INFO=<ID=OMIM,Number=A,Type=Float,Description="This is the fantom enhancer score">';
	echo '#CHROM	START	END	ENHANCERID	SCORE	STRAND';
	#(columns 1-6 as chromosome, start coordinate, end coordinate, enhancer ID, score and strand)
	## NOTE: BED files are 0-based, open coordinates:
	zcat $TEMP_FILE | awk -v OFS='\t' ' { print $1, $2, $3, $4, $5, $6 } ';
	#cat $TEMP_FILE | grep -v '#' | awk -v OFS='\t' ' { print $1, $2, ".", ".", ".", ".", "PASS", "FANTOM="$6 } ';
	} | awk 'NR == 3; NR > 3 {print $0 | "sort -k1,1 -k2,2n -k6,6"}' | bgzip --threads $N_THREADS > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForBed $NAME $GENOME $OUTFILE

#should this be a bed file bc there is no ref and alt data?
## NOTE: BED files are 0-based, open coordinates:
#cat $TEMP | awk -v OFS='\t' ' { print $1, $2, $3, $6 } ' > omim.bed
