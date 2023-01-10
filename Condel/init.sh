#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="http://bbglab.irbbarcelona.org/fannsdb/downloads/fannsdb.tsv.gz"
GENOME=hg19
TEMP_FILE=fannsdb.tsv
OUTFILE=./$GENOME/CONDEL.vcf
NAME=Condel

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	echo '##fileformat=VCFv4.2' > $OUTFILE
	echo '##INFO=<ID=PPH2,Number=A,Type=Float,Description="This is the polyphren2 score">' >> $OUTFILE
	echo '#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO' >> $OUTFILE

	zcat $TEMP_FILE | grep -v '#' | grep -v "CHR" | awk -F'\t' -v OFS='\t' ' { print $1, $2, ".", $4, $5, ".", "PASS", "PPH2="$11 } ' >> $OUTFILE
	runIndexFeatureFile $OUTFILE
	rm $TEMP_FILE
	
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE
