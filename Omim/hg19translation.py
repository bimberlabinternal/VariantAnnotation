#!/usr/bin/env python3
# -*- coding: utf-8 -*-


#
# This is a simple script to generate GRCh37/hg19 genomic coordinate for MIM genes.
#
# You will need the GCF_000001405.25_GRCh37.p13_genomic.gff.gz file which can downloaded from NCBI:
#
#   https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.25_GRCh37.p13/GCF_000001405.25_GRCh37.p13_genomic.gff.gz
#
# And mim2gene.txt which can be downloaded from OMIM:
#
#   https://omim.org/downloads
#


# Imports
import re
import gzip

# Gene dict, K - 'geneID', V - genomic coordinate
geneDict = dict()

# Process the GRCh37 data
with gzip.open('./GCF_000001405.25_GRCh37.p13_genomic.gff.gz', 'rt') as fileHandle:
    for line in fileHandle:

        # Skip comments
        if line.startswith('#'):
            continue

        # Strip trailing new line
        line = line.strip('\n')

        # Get the values
        valueList = line.split('\t')

        # Get the fields
        accessionNumber = valueList[0]
        sequenceType = valueList[2]
        genomicPositionStart = valueList[3]
        genomicPositionEnd = valueList[4]
        identifiers = valueList[8]

        # Skip non-genes
        if sequenceType != 'gene':
            continue

        # Skip non-genes
        if not accessionNumber.startswith('NC_'):
            continue

        # Extract the Entrez Gene ID
        matcher = re.search(r'GeneID:(\d+)', identifiers)
        if not matcher:
            continue
        entrezGeneID = matcher.group(1)

        # Extract the chromosome
        matcher = re.match(r'^NC_(\d{6})\.\d+', accessionNumber)
        if not matcher:
            continue
        chromosome = int(matcher.group(1))
        if chromosome == 23:
            chromosome = 'X'
        elif chromosome == 24:
            chromosome = 'Y'

        # Create the genomic coordinate
        genomicCoordinate = '|'.join([str(chromosome), str(int(valueList[3])-1), valueList[4]])
        
        # Add the genomic coordinate to the gene dict
        if entrezGeneID not in geneDict:
            geneDict[entrezGeneID] = set()
        geneDict[entrezGeneID].add(genomicCoordinate)


skippedGenes = 0
with open('./genemap2.txt') as fileHandle:
    for line in fileHandle:

        # Skip comments
        if line.startswith('#'):
            continue

        # Strip trailing new line
        line = line.strip('\n')

        # Get the values
        line = line.split('\t')
        
        # Get the fields
        entrezGeneID = line[9]        
        
        if entrezGeneID in geneDict:
            genomicCoordinates = geneDict[entrezGeneID]
            if len(genomicCoordinates) > 1:
                #raise Exception('More than one coordinate set: ' + ', '.join(genomicCoordinates))
                skippedGenes += 1
                next
                
            genomicCoordinate = list(genomicCoordinates).pop().split('|')
            mimNumber = line[5]
            ensemblId = line[9]   
            approvedGeneSymbol = line[8]
            phenotypes = line[12]
            
            print('{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}'.format(genomicCoordinate[0], genomicCoordinate[1], genomicCoordinate[2], ensemblId, entrezGeneID, mimNumber, approvedGeneSymbol, phenotypes))

#print('Total genes with duplicate coordinates: ' + str(skippedGenes))