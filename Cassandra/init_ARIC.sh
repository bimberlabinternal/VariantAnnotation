#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

if [ ! -d ARIC ];then
	mkdir ARIC
	cp ARIC.* ARIC/
fi

cd ARIC

GENOME=hg19
TEMP_FILE=ARIC.frequencies.txt.gz
OUTFILE=./$GENOME/ARIC.vcf.gz
NAME=ARIC

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	cp $TEMP_FILE $OUTFILE

	{
	echo '##fileformat=VCFv4.2';
	echo '##INFO=<ID=ARIC,Number=A,Type=Float,Description="This is the ARIC score">';
	echo '#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO';
	zcat $TEMP_FILE | grep -v '#' | grep -v "CHR" | awk -v OFS='\t' ' { print $1, $2, ".", $3, $4, ".", "PASS", "ARIC="$6 } ';
	} | bgzip -f --threads $N_THREADS > $OUTFILE
	
	runIndexFeatureFile $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE

cd ../
cp -r ARIC ../