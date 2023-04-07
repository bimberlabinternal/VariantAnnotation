#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

GENOME=hg19
REPORT_FILE=hg37Report.txt

OUTFILE_PLACENTAL=./$GENOME/phylop_placental.bed
NAME_PLACENTAL=phylop_placental

OUTFILE_VERT=./$GENOME/phylop_vert.bed
NAME_VERT=phylop_vert

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	
	VERT_TEMP=phylop_vert.sga.gz
	PLACENTAL_TEMP=phylop_placental.sga.gz
	downloadSourceFile https://ccg.epfl.ch/mga/hg19/phylop/phylop_vert.sga.gz $VERT_TEMP
	downloadSourceFile https://ccg.epfl.ch/mga/hg19/phylop/phylop_placental.sga.gz $PLACENTAL_TEMP

	# NOTE: the input is in GRCh38, so translate into GRCh37:
	wget -q -O $REPORT_FILE https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.14_GRCh37.p13/GCA_000001405.14_GRCh37.p13_assembly_report.txt
	
	{
 	echo '#CHROM	START	END	PHYLOP_VERT';  	
	python ./hg19translation.py $VERT_TEMP | sort -V -k1,1 -k2,2n -k3,3n | awk -v OFS='\t' ' { print $1, $2-1, $3, $5 } ';
	} > $OUTFILE_VERT
	
	ensureIndexed $OUTFILE_VERT
	
	{
 	echo '#CHROM	START	END	PHYLOP_PLACENTAL';  	
	python ./hg19translation.py $PLACENTAL_TEMP | sort -V -k1,1 -k2,2n -k3,3n | awk -v OFS='\t' ' { print $1, $2-1, $3, $5 } ';
	} > $OUTFILE_PLACENTAL
	
	ensureIndexed $OUTFILE_PLACENTAL
	
	rm $VERT_TEMP
	rm $PLACENTAL_TEMP
	rm $REPORT_FILE
	
	touch $DONE_FILE
fi

createConfigFileForBed $NAME_PLACENTAL $GENOME $OUTFILE_PLACENTAL
createConfigFileForBed $NAME_VERT $GENOME $OUTFILE_VERT


