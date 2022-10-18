#!/bin/bash

set -e
set -x

SCRIPT_DIR=../scripts
source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="https://zenodo.org/record/3928295/files/capice_v1.0_build37_indels.tsv.gz"
GENOME=hg19
TEMP_FILE=capice_v1.0_build37_indels.tsv.gz
OUTFILE=./$GENOME/capice.vcf
NAME=capice

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	echo '##fileformat=VCFv4.2' > $OUTFILE
	echo '##FORMAT=<ID=CAPICE,Number=A,Type=Float,Description="This is the capice score">' >> $OUTFILE
	echo '#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO' >> $OUTFILE

	zcat $TEMP_FILE | grep -v '#' | awk -v OFS='\t' ' { print $1, $2, ".", $3, $4, ".", "PASS", "CAPICE="$5 } ' >> $OUTFILE
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE