#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

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
	
	wget -q -O getGencode.sh https://raw.githubusercontent.com/broadinstitute/gatk/master/scripts/funcotator/data_sources/getGencode.sh
	wget -q -O fixGencodeOrdering.py https://raw.githubusercontent.com/broadinstitute/gatk/master/scripts/funcotator/data_sources/fixGencodeOrdering.py

	chmod +x getGencode.sh
	chmod +x fixGencodeOrdering.py
	bash getGencode.sh
	
	# Normalize file locations:
	mv ./gencode/hg19 ./hg19
	mv ./gencode/hg38 ./hg38
	rm -Rf gencode
	
	rm -Rf getGencode.sh
	rm -Rf fixGencodeOrdering.py
	
	samtools faidx ./hg19/gencode.v34lift37.pc_transcripts.fa
	samtools dict -o ./hg19/gencode.v34lift37.pc_transcripts.dict ./hg19/gencode.v34lift37.pc_transcripts.fa
	gatk IndexFeatureFile -I ./hg19/gencode.v34lift37.annotation.REORDERED.gtf

	samtools faidx ./hg38/gencode.v34.pc_transcripts.fa
	samtools dict -o ./hg38/gencode.v34.pc_transcripts.dict ./hg38/gencode.v34.pc_transcripts.fa
	gatk IndexFeatureFile -I ./hg38/gencode.v34.annotation.REORDERED.gtf

	# MMul10:
	if [ -e mmul10 ];then
		rm -Rf mmul10
	fi
	
	mkdir mmul10
	
	# Now make a fake almost empty file for mmul10:
	echo '>Gene1|Gene1|CDS:1-10' > mmul10/MMul10_transcript.fa
	echo "AAAAAAAAAA" >> mmul10/MMul10_transcript.fa
	
	cp MMul10.gtf mmul10/MMul10.gtf
	cp MMul10.gtf.idx mmul10/MMul10.gtf.idx

	samtools faidx mmul10/MMul10_transcript.fa
	samtools dict -o mmul10/MMul10_transcript.dict mmul10/MMul10_transcript.fa
	
	cp MMul10.gencode.config ./mmul10/gencode.config
	
	touch $DONE_FILE
fi

