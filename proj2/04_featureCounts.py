import subprocess
import glob

number_threads=15
annotation="/home/nicai_zht/ref_data/hg38.knownGene.gtf"
cleanfq_dir="/data1/project/proj2"
deg_dir="/data1/project/proj2/Deg"

# 收集所有sorted bam文件路径
bam_files = glob.glob(f"{cleanfq_dir}/*_align_sorted.bam")
bam_files_str = " ".join(bam_files) # 将所有bam文件路径拼接成一个字符串

print(f"currently featureCounts Expression Quantification for all sorted bam\n",flush=True)
featureCounts_command = f"""
    featureCounts -p --countReadPairs -T {number_threads}
        -t exon -g gene_id 
        -a {annotation}
        -o {deg_dir}/all_counts.txt
        {bam_files_str}
                    """.replace("\n","")
subprocess.run(featureCounts_command,check=True,shell=True)
