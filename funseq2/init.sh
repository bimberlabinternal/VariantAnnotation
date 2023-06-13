#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="http://org.gersteinlab.funseq.s3-website-us-east-1.amazonaws.com/funseq2/hg19_wg_score.tsv.gz"
GENOME=hg19
TEMP_FILE=hg19_wg_score.tsv.gz
OUTFILE=./$GENOME/funseq2.vcf.gz
NAME=funseq2

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	{
	echo '##fileformat=VCFv4.2';
	echo '##INFO=<ID=FS2,Number=A,Type=Float,Description="The funseq2 score">';
	echo '#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO';
	zcat $TEMP_FILE | grep -v '#' | sed 's/^chr//' | awk -F'\t' -v OFS='\t' ' { print $1, $2, $3, $4, ".", "PASS", "FS2="$5 } ';
	} | bgzip --threads $N_THREADS > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE
