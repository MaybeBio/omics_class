import pandas as pd
import argparse

def calculate_enrichment_score(kmer_file,total_obs_count,exp_freq_dict_type,top_m=10):
    """
    Args:
        kmer_file (str): 包含k-mer及其计数的文件路径
        total_obs_count (int): 总的观测计数，用于计算top k-mer文件中每一行的观测频率，
        通过shell命令计算：cut -d " " -f 2 该k-mer文件 | awk '{sum+=$1} END {print sum}'
        exp_freq_dict_type (str):预期频率字典类型，取值为"grch38_p14"或"t2t"，分别对应GRCh38_p14和T2T基因组的预期频率
        也可以自己设置1个参数，通过exp_freq_dict (dict): 预期频率字典
        top_m (int): 在计算富集分数之后，取前top_m个k-mer的富集分数,默认是10

    Fun:
        计算富集分数，公式为：富集分数 = 观测频率 / 预期频率
        其中观测频率 = k-mer计数 / 总观测计数
        预期频率是一个字典，包含每个碱基的预期频率
        最终计算每个k-mer的富集分数，但是只返回top_m个
    """
    top_kmer = pd.read_csv(kmer_file,sep=" ",header=None,names=["kmer","count"])

    # 计算观测频率
    top_kmer["obs_freq"] = top_kmer["count"] / total_obs_count

    # 计算预期频率
    # 这里需要拆分k-mer，计算每个碱基的预期频率，注意第一列是个可迭代器，每个元素k-mer又是一个迭代器，用for i in top_kmer["kmer"]不行
    grch38_p14_freq = {"A": 0.2942844830001953, "C": 0.20484219378112098, "G": 0.20569626883883788, "T": 0.2951770543798458}
    t2t_freq = {"A": 0.2963722334173198, "C": 0.20328436340583256, "G": 0.20425501675882426, "T": 0.2960883864180234}
    if exp_freq_dict_type == "grch38_p14":
        exp_freq_dict = grch38_p14_freq
    elif exp_freq_dict_type == "t2t":
        exp_freq_dict = t2t_freq
    else:
        raise ValueError("exp_freq_dict_type must be 'grch38_p14' or 't2t'")

    def calc_exp_freq(kmer,exp_freq_dict):
        freq = 1.0
        for base in kmer:
            freq *= exp_freq_dict.get(base,0) # 如果碱基不在预期频率字典中，默认为0
        return freq
    
    top_kmer["exp_freq"] = top_kmer["kmer"].apply(lambda x: calc_exp_freq(x, exp_freq_dict))
    
    # 计算富集分数
    top_kmer["enrichment_score"] = top_kmer["obs_freq"] / top_kmer["exp_freq"]

    # 取前top_m个k-mer
    top_kmer = top_kmer.sort_values(by="enrichment_score", ascending=False).head(top_m)

    # 输出为tsv格式文件
    top_kmer.to_csv(kmer_file.replace(".txt", f"_top{top_m}.tsv"), sep="\t", header=True, index=False)

# 使用parse_args()函数来解析命令行参数
if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="为每一个k-mer文件中的k-mer计算富集分数，并输出前top_m个k-mer")
    parser.add_argument("kmer_file", type=str, help="kmer文件路径")
    parser.add_argument("total_obs_count", type=int, help="该k-mer文件的总观测计数")
    parser.add_argument("exp_freq_dict_type", type=str, help="预期频率字典类型，取值为'grch38_p14'或't2t'，分别对应GRCh38_p14和T2T基因组的预期频率")
    parser.add_argument("--top_m", type=int, default=10, help="在计算富集分数之后，取前top_m个k-mer的富集分数,默认是10")

    args = parser.parse_args()

    calculate_enrichment_score(args.kmer_file, args.total_obs_count, args.exp_freq_dict_type, args.top_m)
    
    
