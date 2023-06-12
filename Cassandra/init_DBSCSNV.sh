#!/bin/bash

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh


cd DBSCSNV/

GENOME=hg19
TEMP_FILE=DBSCSNV.txt.gz
OUTFILE=./$GENOME/DBSCSNV.vcf.gz
NAME=DBSCSNV

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME

	{
	echo '##fileformat=VCFv4.2';
	echo '##INFO=<ID=DBSCSNV_score,Number=A,Type=Float,Description="This is the DBSCSNV score">';
	echo '#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO';
	zcat $TEMP_FILE | grep -v '#' | grep -v "chr" | awk -F'\t' -v OFS='\t' ' { print $1, $2, ".", $3, $4, ".", "PASS", "DBSCSNV_score="$38 } '| sort -V -k2,2 -k3,3n -k4,4n;
	} | bgzip --threads $N_THREADS > $OUTFILE

	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE

cd ../
cp -r DBSCSNV ../