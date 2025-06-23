#!/bin/bash

# 主要是-f选项

featureCounts -T 20 -a /data1/project/proj1/annotations/T2T.gtf \
    -o /data1/project/proj1/result/T2T_T2T_exon_counts.txt  \
        -t exon -f  \
        -g  gene_id \
        -R CORE --Rpath /data1/project/proj1/result  \
        -J -A /data1/project/proj1/chr_alias3.txt /data1/project/proj1/T2T/*.bam

