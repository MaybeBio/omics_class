#!/bin/bash


featureCounts -T 20 -a /data1/project/proj1/annotations/GRCh38.gtf \
    -o /data1/project/proj1/output/results/grch38_refseq_exon_counts.txt  \
        -t exon -f  \
        -g  transcript_id \
        -J -A /data1/project/proj1/chr_alias2.txt /data1/project/proj1/output/aligned/GRCH38/*_sorted_2718Y.bam
