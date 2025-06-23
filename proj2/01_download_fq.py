# 使用python小脚本
import subprocess

# 数据下载的一些参数设置
num_threads = 15    # 下载使用的线程数
Outdir = "/data1/project/proj2"
Sra_file = "/data1/project/SRR_Acc_List.txt"

# with打读
with open(Sra_file,"r") as sras:
    for sra in sras:
        sra = sra.strip("\n") # 去掉每行的换行符
        print(f"currently downloading {sra}\n")
        # 当然prefetch也可以以SRR_Acc_List.txt文件输入下载所有的sra，次数分开只是为了在不开log的情况下好debug，以及faster-dump的时候还是要for循环
        prefetch = f"prefetch {sra} --max-size 50G -O {Outdir}" 
        # 优先使用run，其次使用call，然后因为有些软件的环境变量设置在zsh的zshrc文件中，而不是在bash中
        # 所以要么提供软件执行文件bin的绝对路径，要么在参数命令中加入zsh -c在zsh中执行，要么在bash中也设置环境变量的PATH
        
        # 如果shell=True,需要设置bash
        # 如果不设置shell=True，而是使用zsh，需要在subprocess.run中传递命令列表（注意参数、subcommand都要解析拆开）
        subprocess.run(prefetch,check=True,shell=True) 
         
        print (f"generating fastq for {sra}")
        fasterq_dump = f"fasterq-dump {sra} -e {num_threads} -O {Outdir}" 
        subprocess.run(fasterq_dump,check=True,shell=True)
        
