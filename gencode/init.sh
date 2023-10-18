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
	sed -i 's/wget/wget -q/' getGencode.sh
	
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
	
	HG19_FA=`find ./gencode/hg19/ -name '*transcripts.fa'`
	samtools faidx $HG19_FA
	
	DICT=`echo $HG19_FA | sed 's/fa/dict/'`
	samtools dict -o $DICT $HG19_FA
	
	GTF=`find ./gencode/hg19/ -name '*REORDERED.gtf'`
	gatk IndexFeatureFile -I $GTF

	HG38_FA=`find ./gencode/hg38/ -name '*transcripts.fa'`
	samtools faidx $HG38_FA
	
	DICT=`echo $HG38_FA | sed 's/fa/dict/'`
	samtools dict -o $DICT $HG38_FA
	
	GTF=`find ./gencode/hg38/ -name '*REORDERED.gtf'`
	gatk IndexFeatureFile -I $GTF

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

