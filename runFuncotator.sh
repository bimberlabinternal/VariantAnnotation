#!/bin/bash
#
#SBATCH --job-name=funcotator
#SBATCH --ntasks=1
#SBATCH --get-user-env
#SBATCH --output=/home/groups/BimberLab/Exacloud/test_datasource/customDataSource/funcotator.log
#SBATCH --error=/home/groups/BimberLab/Exacloud/test_datasource/customDataSource/funcotator.log
#SBATCH --cpus-per-task=8
#SBATCH --mem=64000
#SBATCH --partition=exacloud
#SBATCH --time=0-2

set -e
set -x

VCF=/home/groups/BimberLab/Exacloud/test_datasource/customDataSource/simpleTest.vcf

GATK=/home/groups/BimberLab/Exacloud/mulch/TOOLS/gatk-4.2.6.1/gatk
REF=/home/groups/prime-seq/production/Shared/@files/.referenceLibraries/99/99_Human_GRCh37.p13_Ensembl.fasta
DATA_SOURCE=/home/groups/BimberLab/Exacloud/test_datasource/customDataSource

OUT_PREFIX=`basename $VCF ".vcf"`
OUTPUT=${OUT_PREFIX}.funcotated.maf

$GATK IndexFeatureFile -I $VCF

$GATK Funcotator \
	--variant $VCF \
	--reference $REF \
	--ref-version hg19 \
	--data-sources-path $DATA_SOURCE \
	--output $OUTPUT \
	--output-file-format MAF

# TODO: these fields are probably no longer correct:
cat $OUTPUT | grep -A 1000 Hugo_Symbol | awk -F '\t' -v OFS='\t' ' { print $5, $6, $9, $86, $87, $88, $89, $90, $91, $92, $93 } '
