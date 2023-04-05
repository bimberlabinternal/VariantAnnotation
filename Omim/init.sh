#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh


# OMIM fields:
# Chromosome (NCBI)
# Genomic position start * (NCBI)
# Genomic position end (NCBI)
# Cyto location (OMIM)
# Computed cyto location (UCSC)
# MIM Number for Gene/Locus (OMIM)
# Gene symbols (OMIM)
# Gene name (OMIM)
# Approved gene symbol (HGNC)
# Entrez gene ID (NCBI)
# Ensembl gene ID (Ensembl)
# Comments (OMIM)
# Phenotype(s) (OMIM)
# Mouse gene symbol & ID (MGI)
hg37="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.25_GRCh37.p13/GCF_000001405.25_GRCh37.p13_genomic.gff.gz"

URL=https://omim.org/static/omim/data/genemap2.txt
GENOME=hg19
TEMP_FILE=genemap2.txt
OUTFILE=./$GENOME/omim.bed
GFF=GCF_000001405.25_GRCh37.p13_genomic.gff.gz
NAME=omim

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	# NOTE: the input is in GRCh38, so translate into GRCh37:
	wget -q -O $GFF $hg37
	
	{
 	echo '#CHROM	START	END	ENSEMBLEGENE	ENSEMBLEID	MIMNUMBER	GENESYMBOL	PHENOTYPES';  	
	python ./hg19translation.py | sort -V -k1,1 -k2,2n -k3,3n;
	} > $OUTFILE
	
	ensureIndexed $OUTFILE
	
	rm $TEMP_FILE
	rm $GFF
	
	touch $DONE_FILE
fi

createConfigFileForBed $NAME $GENOME $OUTFILE
