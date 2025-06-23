#!/usr/bin/bash
# 可以尝试使用zsh

num_threads=10
Out_dir="/data1/project/proj2"
Sra_file="/data1/project/SRR_Acc_List.txt"

mkdir -p $Out_dir

for sra in $(cat $Sra_file):
do
    echo "currently Downloading ${sra}\n"
    preftech ${sra} --max-size 50G -O ${Outdir}

    echo "generating fastq files from ${sra}\n"
    fasterq-dump --threads ${num_threads} -O ${Outdir}\${sra} ${sra}
done