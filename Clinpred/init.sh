#!/bin/bash

set -e
set -x

SCRIPT_DIR=../scripts
source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="https://cvmfs-hubs.vhost38.genap.ca/~alirezai/ClinPred"
GENOME=hg19
TEMP_FILE=Clinpred.txt
OUTFILE=./$GENOME/ClinPred.vcf
NAME=clinpred

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	echo '##fileformat=VCFv4.2' > $OUTFILE
	echo '##INFO=<ID=ClinPredScore,Number=A,Type=Float,Description="This is the ClinPredScore score">' >> $OUTFILE
	echo '#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO' >> $OUTFILE

	cat $TEMP_FILE  | tail -n +2 | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1, $2, ".", $3, $4, ".", "PASS", "ClinPredScore="$5 } ' >> $OUTFILE
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE
