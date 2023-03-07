#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

#GRASP - Analysis of genotype-phenotype results from 1390 genome-wide association studies.
#visit for update https://grasp.nhlbi.nih.gov/FullResults.aspx

cd Grasp

GENOME=hg19
TEMP_FILE=grasp.txt.gz
OUTFILE=./$GENOME/GRASP.vcf.gz
NAME=GRASP

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME

	{
	echo '##fileformat=VCFv4.2';
	echo '##INFO=<ID=GRASP,Number=A,Type=Float,Description="This is the GRASP gwas p value for phenotype assosication">';
	echo '#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO';
	zcat $TEMP_FILE | grep -v '#' | grep -v "CHR" | awk -F'\t' -v OFS='\t' ' $4!="-" ' | awk -F'\t' -v OFS='\t' ' $4!="(HETEROZYGOUS)" ' | awk -F'\t' -v OFS='\t' ' { print $1, $2, ".", $3, $4, ".", "PASS", "GRASP="$5 } ';
	} > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE

cd ../
cp -r Grasp ../