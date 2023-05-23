#!/bin/bash

set -e 
set -x

#export DOWNLOAD_LINE_LIMIT=1000
#export FORCE_REPROCESS=0
export SKIP_LARGE_SOURCES=1
export OMIM_KEY=Zvf47keUQR-KdH2zrXfcew
export ALLOW_DATASOURCE_REUSE=1

bash initializeAll.sh
