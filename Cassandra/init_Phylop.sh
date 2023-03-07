#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh


#Phylop phylop - Phylop conservation scores
#higher score is more conserved between species
cd Phylop/

GENOME=hg19
TEMP_FILE=phylop.txt.gz
OUTFILE=./$GENOME/phylop.bed
NAME=Phylop

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME

	{
	echo '#CHROM	START	END	PhylopSCORE';
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1, $2,  $2+=1, $3 } ' | sort -V -k1,1 -k2,2n;
	} > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForBed $NAME $GENOME $OUTFILE

cd ../
cp -r Phylop/ ../