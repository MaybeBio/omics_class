import gzip
import pandas as pd
from collections import defaultdict

# 1. 解析 GTF 文件，构建位置→基因的映射字典 
def build_genome_index(gtf_path):
    """
    构建基因组位置到基因ID的映射字典
    格式: {(chrom, pos, strand): set(gene_ids)}
    """
    index = defaultdict(set)
    
    # 自动处理 gzip 压缩文件
    open_func = gzip.open if gtf_path.endswith('.gz') else open
    mode = 'rt' if gtf_path.endswith('.gz') else 'r'
    
    with open_func(gtf_path, mode) as f:
        for line in f:
            if line.startswith('#'):  # 跳过注释行
                continue
                
            parts = line.strip().split('\t')
            if len(parts) < 9:
                continue
                
            chrom, source, feature, start, end, score, strand, frame, attributes = parts
            
            # 只处理 exon 和 transcript 特征
            if feature not in ['exon', 'transcript']:
                continue
                
            # 解析属性字段
            attr_dict = {}
            for attr in attributes.split(';'):
                attr = attr.strip()
                if not attr:
                    continue
                if ' ' in attr:
                    key, val = attr.split(' ', 1)
                    attr_dict[key] = val.strip('"')
            
            # 获取 gene_id
            gene_id = attr_dict.get('gene_id')
            if not gene_id:
                continue
                
            # 将位置转换为整数
            try:
                start = int(start)
                end = int(end)
            except ValueError:
                continue
                
            # 为每个位置创建索引
            for pos in range(start, end + 1):
                key = (chrom, pos, strand)
                index[key].add(gene_id)
                
    return index

# 2. 为 jcounts 文件添加基因注释
def annotate_jcounts(jcounts_path, gtf_path, output_path):
    # 构建基因组索引
    genome_index = build_genome_index(gtf_path)
    
    # 读取 jcounts 文件
    jcounts_df = pd.read_csv(jcounts_path, sep='\t', comment='#')
    
    # 准备存储结果的列表
    sp1_genes = []
    sp2_genes = []
    
    # 为每一行查找基因
    for _, row in jcounts_df.iterrows():
        # 处理 SP1
        chrom1 = f"chr{row['Chr_SP1']}" if not str(row['Chr_SP1']).startswith('chr') else row['Chr_SP1']
        pos1 = row['Location_SP1']
        strand1 = row['Strand_SP1']
        
        sp1_key = (chrom1, pos1, strand1)
        genes1 = genome_index.get(sp1_key, set())
        sp1_genes.append(";".join(genes1) if genes1 else "NA")
        
        # 处理 SP2
        chrom2 = f"chr{row['Chr_SP2']}" if not str(row['Chr_SP2']).startswith('chr') else row['Chr_SP2']
        pos2 = row['Location_SP2']
        strand2 = row['Strand_SP2']
        
        sp2_key = (chrom2, pos2, strand2)
        genes2 = genome_index.get(sp2_key, set())
        sp2_genes.append(";".join(genes2) if genes2 else "NA")
    
    # 添加新列
    jcounts_df['SP1_gene'] = sp1_genes
    jcounts_df['SP2_gene'] = sp2_genes
    
    # 保存结果
    jcounts_df.to_csv(output_path, sep='\t', index=False)
    print(f"结果已保存至: {output_path}")
    return jcounts_df

# 3. 使用
if __name__ == "__main__":
    # 输入文件路径
    jcounts_file = "/data1/project/proj1/result/grch38_gencode_exon_counts.txt.jcounts"
    gtf_file = "/data1/project/proj1/annotations/gencode.gtf"  
    output_file = "/data1/project/proj1/result/grch38_gencode_exon_annotated_jcounts.txt"
    
    # 执行注释
    annotated_df = annotate_jcounts(jcounts_file, gtf_file, output_file)
    
    # 查看前几行验证
    print(annotated_df[['Chr_SP1', 'Location_SP1', 'SP1_gene', 
                       'Chr_SP2', 'Location_SP2', 'SP2_gene']].head())
