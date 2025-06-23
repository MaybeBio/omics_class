#!/bin/bash

# 主要是-f选项

featureCounts -T 20 -a /data1/project/proj1/annotations/gencode.gtf \
    -o /data1/project/proj1/result/grch38_gencode_exon_counts.txt  \
        -t exon -f  \
        -g  gene_id \
        -R CORE --Rpath /data1/project/proj1/result  \
        -J -A /data1/project/proj1/chr_alias.txt /data1/project/proj1/GRCH38/*.bam
