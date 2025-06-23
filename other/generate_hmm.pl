#!/usr/bin/perl -w
#  指定使用 Perl 解释器运行脚本，并启用警告模式
use strict;
#  强制使用严格的变量声明规则，避免潜在的错误


my ($sample) = @ARGV;
# 从命令行参数中获取文件名（sample）

my $usage = "This script is to generate 10 lines of observed results of flipping coins.
Can you guess at which point the coin is changed?
usage: $0 sample
sample.txt is the file to score the flipping results, and this script will generate an a
dditional file as sample.sta to keep the information where the coin changed.
Of course, you can change the name of \"sample\" to any word you like.
";

die $usage if @ARGV <1; 
# 如果没有提供参数，则打印用法说明并退出
my $sta=$sample.".sta";
# 定义状态文件的名称（sample.sta）
open(OUT,">$sample")||die("Cannot write result to $sample!\n");
# 打开输出文件（观测序列文件），如果文件无法打开，则打印错误信息并退出
open(STA,">$sta")||die("Cannot write result to $sta!\n");
# 打开状态文件（记录硬币切换点），如果文件无法打开，则打印错误信息并退出

#randomization
# State：F is fair，B is biased，E is end；Obs：H is head，T is tail；我们要和partb中提供的参数一致

# 观测序列概率矩阵/输出序列概率矩阵，与partb中的参数一致
my $p_FH = 0.5; # 第一枚硬币/公平硬币观测/输出为正面的概率
my $p_BH = 0.8; # 第二枚硬币/有偏硬币观测/输出为正面的概率

# 状态转移概率矩阵，与partb中的参数一致
my $p_F2B = 0.01; # 从公平硬币切换到有偏硬币的概率
my $p_B2E = 0.05; # 从有偏硬币切换到结束的概率
my $p_F2F = 0.99; # 从公平硬币保持为公平硬币的概率
my $p_B2B = 0.95;  # 从有偏硬币保持为有偏硬币的概率



#generation,生成 10 行观测序列
for(my $i=0; $i<10; $i++){
#start from coin 1/F
    flip_coin($p_FH);
    print STA "F";
# 使用硬币 F 生成第一次投掷结果
# 并在状态文件中记录当前使用的是硬币 F

#flip coin 1/F
    while($p_F2B < rand(1)){
        flip_coin($p_FH);
        print STA "F";
    }
    # 模拟硬币 F 的连续投掷，直到切换到硬币 B
    # 使用硬币 B 生成一次投掷结果
#change to coin 2/B
    flip_coin($p_BH);
    print STA "B";
    # 使用硬币 B 生成一次投掷结果
    # 并在状态文件中记录当前使用的是硬币 B
#flip coin 2/B
    while($p_B2E < rand(1)){
        flip_coin($p_BH);
        print STA "B";
    }
    # 模拟硬币 B 的连续投掷，直到切换到结束
    # 并在状态文件中记录当前使用的是硬币 B
#change to END
    print OUT "\n";
    print STA "\n";
    # 在输出文件和状态文件中换行
}
close OUT;

# 定义一个子程序，用于模拟硬币投掷
sub flip_coin{
    my ($pH) = @_;
    #  获取硬币正面朝上的概率
    if($pH>rand(1)){
        print OUT "H";
    }
    else{
        print OUT "T";
    }
    # 如果随机数小于正面概率，则输出 H（正面）；否则输出 T（反面）
}
