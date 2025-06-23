import subprocess

number_threads=15
Ref_Genome_dir="/home/nicai_zht/ref_data/hg38/genome"
Sra_file="/data1/project/SRR_Acc_List.txt"
cleanfq_dir="/data1/project/proj2"

with open(Sra_file,"r") as sras:
    for sra in sras:
        sra = sra.strip("\n")
        print(f"currently hisat2 mapping for {sra}\n",flush=True)
        hisat2_command = f"""
        hisat2 -p {number_threads} -x {Ref_Genome_dir} 
            -1 {cleanfq_dir}/{sra}_1_clean.fastq 
                -2 {cleanfq_dir}/{sra}_2_clean.fastq
                    -S {cleanfq_dir}/{sra}_align.sam
                        --summary-file {cleanfq_dir}/{sra}_align_summary
                            """.replace("\n","")
        subprocess.run(hisat2_command,check=True,shell=True)
        
        # 因为samtools转换bam以及sort一般不需要中间文件，在shell中的管道写法，在python中也可以
        print(f"currently samtools converting and sort sam for {sra}\n",flush=True)
        sam2bam_sort = f"samtools view -@ {number_threads} -bS {cleanfq_dir}/{sra}_align.sam | samtools sort -@ {number_threads} -o {cleanfq_dir}/{sra}_align_sorted.bam"
        subprocess.run(sam2bam_sort,check=True,shell=True)
