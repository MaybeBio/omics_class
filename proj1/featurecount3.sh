#!/bin/bash

# 主要是-f选项

featureCounts -T 30 -a /data1/project/proj1/annotations/T2T1.gtf \
    -o /data1/project/proj1/output/results/T2T_T2T_gene_counts.txt  \
        -t exon   \
        -g  gene_id \
        -R CORE --Rpath /data1/project/proj1/output/results \
        -J  -A /data1/project/proj1/chr_alias3.txt /data1/project/proj1/output/aligned/T2T/*_sorted_2718Y.bam