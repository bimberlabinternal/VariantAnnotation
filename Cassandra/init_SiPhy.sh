#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

#SiPhy documentation
# form datasource for SiPhy, siphy - Detects bases under selection.
#    Start position of the annotation.
#    End position of the annotation.
#    Annotation name.
#    Annotation orientation.
#    Estimated scalar rescaling (ω) of the neutral rate that maximizes the likelihood of the model in the window alignment.
#    Log-odds ratio of the fitted vs the neutral likelihodds (SiPhy writes negative likelihodds for ω greater than 1 to distinguish rapid vs slow evolving sequence).
#    Theoretical chis-sequared p-value of the obtained log-odds ratio.
#    Minimum branch length in annotation after removing species aligned with gaps or missing sequence.



if [ ! -d SiPhy ];then
	mkdir SiPhy
	mv siphy.* SiPhy/
fi

cd SiPhy

GENOME=hg19
TEMP_FILE=siphy.txt.gz
OUTFILE=./$GENOME/SiPhy.bed
NAME=SiPhy

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME

	{
	echo '#CHROM	START	END	CHISQPVAL';
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1, $2, $2+=1, $7 } ' | sort -V -k1,1 -k2,2n;
	} > $OUTFILE

	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForBed $NAME $GENOME $OUTFILE

cd ../
cp -r SiPhy/ ../



