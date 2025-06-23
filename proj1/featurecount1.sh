#!/bin/bash

# 主要是-f选项
featureCounts -T 15 -a /data1/project/proj1/annotations/gencode.v40.chr_patch_hapl_scaff.annotation.gff3 \
    -o /data1/project/proj1/output/results/grch38_gencode_exon_counts.txt  \
        -t exon -f  \
        -g  exon_id \
        -J -A /data1/project/proj1/chr_alias.txt /data1/project/proj1/output/aligned/GRCH38/*_sorted_2718Y.bam


        