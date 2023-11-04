import gzip
import os
import sys
import re

natsort = lambda s: [int(t) if t.isdigit() else t.lower() for t in re.split('(\d+)', s)]

# Establish allowable fields:
fields=[]
lineNum=0
with open('../fieldConfig.txt', 'r') as fieldInfo:
    for line in fieldInfo:
        lineNum += 1
        if lineNum == 1:
            continue
        
        line = line.strip().split('\t')
        if line[1] != 'dbNSFP':
            continue
            
        fields.append(line[2])

sys.stderr.write('Total fields to include: ' + str(len(fields)) + '\n')

files = [f for f in os.listdir('.') if re.match(r'dbNSFP4.4a_variant.*\.gz', f)]
files = sorted(files, key=natsort)

for fn in files:
    sys.stderr.write('Processing file: ' + fn + '\n')

    lineNum=0
    fieldToIdx = {}
    with gzip.open(fn, 'rt') as inputFile:
        for line in inputFile:
            lineNum += 1
            line = line.strip().split('\t')
            if lineNum == 1:
                header = line
                for fieldName in fields:
                    if header.index(fieldName) > -1:
                        fieldToIdx[fieldName] = header.index(fieldName)
                
                continue
            
            infoFields = []
            for fieldName in fieldToIdx.keys():
                val = line[fieldToIdx[fieldName]]
                val = re.sub(r';+$', '', val)
                val = val.split(';')
                while '' in val:
                    val.remove('')
    
                while '.' in val:
                    val.remove('.')

                val = '|'.join(set(val))
                
                if val:
                    # Replace special characters
                    fieldName = fieldName.replace('+', '_')
                    fieldName = fieldName.replace(' ', '_')
                    infoFields.append(fieldName + '=' + val)
            
            # Contig, Pos, ID, Ref, Alt, QUAL, Filter, INFO
            sys.stdout.write('\t'.join([line[0], '.', line[1], line[2], line[3], '.', 'PASS', ';'.join(infoFields)]) + '\n')