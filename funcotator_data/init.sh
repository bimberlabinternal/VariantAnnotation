#!/bin/bash

set -e
set -x

SCRIPT_DIR=../scripts
source ${SCRIPT_DIR}/initFunctions.sh

$GATK FuncotatorDataSourceDownloader --somatic --validate-integrity --extract-after-download
$GATK FuncotatorDataSourceDownloader --germline --validate-integrity --extract-after-download

cp -r funcotator_dataSources.v1.7.20200521g/* ../
cp -r funcotator_dataSources.v1.7.20200521s/* ../


