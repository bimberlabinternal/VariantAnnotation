#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="https://cvmfs-hubs.vhost38.genap.ca/~alirezai/ClinPred"
GENOME=hg19
TEMP_FILE=Clinpred.txt
OUTFILE=./$GENOME/ClinPred.vcf.gz
NAME=Clinpred

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	{
	echo '##fileformat=VCFv4.2';
	echo '##INFO=<ID=ClinPredScore,Number=A,Type=Float,Description="The pre-computed ClinPred score for all possible human missense variants in the exome">';
	echo '#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO';
	cat $TEMP_FILE  | tail -n +2 | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1, $2, ".", $3, $4, ".", "PASS", "ClinPredScore="$5 } ';
	} | bgzip --threads $N_THREADS > $OUTFILE

	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE
