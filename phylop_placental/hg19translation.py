#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import gzip
import sys

inputFile = sys.argv[1]

contigMap = dict()
with open('./hg37Report.txt') as fileHandle:
    for line in fileHandle:

        # Skip comments
        if line.startswith('#'):
            continue

        # Strip trailing new line
        line = line.strip('\n')

        # Get the values
        valueList = line.split('\t')

        # Get the fields
        contig = valueList[0]
        id = valueList[6]

        contigMap[id] = contig


with gzip.open(inputFile, 'rt') as fileHandle:
    for line in fileHandle:

        # Skip comments
        if line.startswith('#'):
            continue

        # Strip trailing new line
        line = line.strip('\n')

        # Get the values
        line = line.split('\t')

        if line[0] in contigMap:
            line[0] = contigMap[line[0]]

        print('\t'.join(line))
