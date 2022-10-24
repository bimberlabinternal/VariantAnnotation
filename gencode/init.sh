#!/bin/bash

set -e
set -x

SCRIPT_DIR=../scripts
source ${SCRIPT_DIR}/initFunctions.sh

if [[ `isProcessingCompleted` == 0 ]];then
	if [ -e gencode ];then
		rm -Rf gencode
	fi
	
	if [ -e hg19 ];then
		rm -Rf hg19
	fi
	
	if [ -e hg38 ];then
		rm -Rf hg38
	fi
	
	wget -O getGencode.sh https://raw.githubusercontent.com/broadinstitute/gatk/master/scripts/funcotator/data_sources/getGencode.sh
	wget -O fixGencodeOrdering.py https://raw.githubusercontent.com/broadinstitute/gatk/master/scripts/funcotator/data_sources/fixGencodeOrdering.py

	chmod +x getGencode.sh
	bash getGencode.sh
	
	# Normalize file locations:
	mv ./gencode/hg19 ./hg19
	mv ./gencode/hg38 ./hg38
	rm -Rf gencode
	
	rm -Rf getGencode.sh
	rm -Rf fixGencodeOrdering.py

	# MMul10:
	if [ -e mmul10 ];then
		rm -Rf mmul10
	fi
	
	# wget https://ftp.ensembl.org/pub/release-108/gtf/macaca_mulatta/Macaca_mulatta.Mmul_10.108.gtf.gz
	# mv Macaca_mulatta.Mmul_10.108.gtf.gz ./mmul10/
	# See this option: https://bedtools.readthedocs.io/en/latest/content/tools/maskfasta.html
	
	touch $DONE_FILE
fi

