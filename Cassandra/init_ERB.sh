#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

# ERBCTA - Activity prediction from Ensembl Regulatory Build
#***ERBSUM - Ensembl Regulatory build summary.
# ERBTFBS - Predicted TFBS from Ensembl Regulatory Build. labled as datasource TFBS
# the summary file is identifiable and so this data soruce should be noted is most likley inteded to be the ERBSUM cassandra source

cd ERB/
GENOME=hg19
TEMP_FILE=ERB_summary.bed.gz
OUTFILE=./$GENOME/ERBSUM.table
NAME=ERBSUM

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME

	{
	echo 'HEADER	CHROM	START	END	INFO';
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1":"$2+1"-"$3, $1, $2+1, $3, $5 } ' | sort -V -k2,2 -k3,3n -k4,4n;
	} > $OUTFILE

	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForTable $NAME $GENOME $OUTFILE

cd ../
cp -r ERB ../