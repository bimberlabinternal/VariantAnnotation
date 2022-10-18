#!/bin/bash

set -e
set -x

SCRIPT_DIR=../scripts
source ${SCRIPT_DIR}/initFunctions.sh

# This file reports data in 1-based format (https://github.com/HAShihab/fathmm-MKL)
URL="http://fathmm.biocompute.org.uk/database/fathmm-MKL_Current.tab.gz"
GENOME=hg19
TEMP_FILE=fathmm-MKL_Current.tab.gz
OUTFILE=./$GENOME/FATHMM.vcf.gz
NAME=fathmm

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	{
	echo '##fileformat=VCFv4.2';
	echo '##FORMAT=<ID=F_NC,Number=A,Type=Float,Description="This is the fathmm-MKL noncoding score, which is a prediction of the functional consequence of the variant. Predictions are given as p-values in the range [0, 1]: values above 0.5 are predicted to be deleterious, while those below 0.5 are predicted to be neutral or benign. P-values close to the extremes (0 or 1) are the highest-confidence predictions that yield the highest accuracy.">';
	echo '##FORMAT=<ID=F_NCG,Number=A,Type=Float,Description="These are the functional groups defined by the fathmm-MKL non-coding score, indicating the categories of functional consequence. See the fanthamm paper for their meanings">';
	echo '##FORMAT=<ID=F_C,Number=A,Type=Float,Description="This is the fathmm-MKL coding score, which is a prediction of the functional consequence of the variant. Predictions are given as p-values in the range [0, 1]: values above 0.5 are predicted to be deleterious, while those below 0.5 are predicted to be neutral or benign. P-values close to the extremes (0 or 1) are the highest-confidence predictions that yield the highest accuracy.">';
	echo '##FORMAT=<ID=F_CG,Number=A,Type=Float,Description="These are the functional groups defined by the fathmm-MKL coding score, indicating the categories of functional consequence. See the fanthamm paper for their meanings.">';
	echo '#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO';
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' {  gsub(/ /, "_", $9); print $1, $2, ".", $4, $5, ".", "PASS", "F_NC="$6";F_NCG="$7";F_CG="$8";F_CG="$9 } ';
	} | bgzip -f --threads $N_THREADS > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForBed $NAME $GENOME $OUTFILE
