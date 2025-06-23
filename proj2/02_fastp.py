# fastp --help &> fastp.txt
import subprocess
q=20 # 质控Q20标准，＜20即低质量
u=30 # 限制允许存在的低质量碱基比例
num_threads=15
Sra_file="/data1/project/SRR_Acc_List.txt"
rawfq_dir="/data1/project/proj2"


with open(Sra_file,"r") as sras:
    for sra in sras:
        sra = sra.strip("\n") # 去掉每行的换行符

        print(f"currently fastp quality control for {sra}\n", flush=True)
        fastp_command = f"""
        fastp -i {rawfq_dir}/{sra}_1.fastq 
            -o {rawfq_dir}/{sra}_1_clean.fastq    
                -I {rawfq_dir}/{sra}_2.fastq 
                    -O {rawfq_dir}/{sra}_2_clean.fastq 
                        -h {rawfq_dir}/{sra}_fastp.html 
                            -q {q} -u {u} -w {num_threads}""".replace("\n","") 
        # 此处使用"""更加清晰换行，最后必须用.replace("\n","")去掉换行符
        subprocess.run(fastp_command,check=True,shell=True)
