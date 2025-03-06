#!/usr/bin/perl -w 

# 表明这是一个perl脚本，-w表示打开警告
# 参考https://www.runoob.com/perl/perl-environment.html

use strict;
# use strict表示使用严格模式，这样可以避免一些不规范的写法

my ($blast_out) = @ARGV;
# 类似于shell脚本中 outputfile=$1这种写法
# 传给脚本的命令行参数列表,参考https://www.runoob.com/perl/perl-special-variables.html
# 变量定义使用my关键字，生命期直到其所在的代码块结束或者文件的末尾
# 从 @ARGV 数组中取出第一个元素，并将其赋给 $blast_out，与my $blast_out = @ARGV不同，后者会被赋予数组长度也就是元素数量
# 与my ($arg1, $arg2, $arg3) = @ARGV;写法区分

my $usage = "This script is to get the best hit from blast output file with 1 input sequence.
usage: $0 <blast_output_file>
";
# 定义一个字符串变量，用于提示用户如何使用该脚本,$0表示脚本名称

die $usage if @ARGV<1;
# 如果参数个数小于1，输出提示信息，注意die语句会立即终止脚本执行

open(BLASTOUT,$blast_out)||die("open $blast_out error!\n");
# 打开blast输出文件，保存到文件句柄BLASTOUT中，如果打开失败，输出错误信息

# 然后是初始化变量以存储
my $query = "";  # 查询序列的标识符
my $score = "";	# 最佳匹配的得分
my $p_value = ""; # 最佳匹配的P值
my $hit = "";	# 最佳匹配的标识符
my $flag = 0;	# 标志位，用于判断是否到了匹配结果的部分
while(<BLASTOUT>){
	# while循环读取文件句柄BLASTOUT中的每一行
    chomp;
	# chomp函数用于去掉字符串末尾的换行符
    if($flag == 0){
	if(/^Query=\s*(\w+)/){
	    $query = $1;
	}
	# 匹配Query=开头的行，提取查询序列的标识符，保存到$query中
	# 其实就是捕获Query=开头的行中的除开空格部分的单词字符，第1个捕获组

	elsif(/^Sequences producing High-scoring Segment Pairs:/){
	    $flag = 1;
	}
	# 匹配到Sequences producing High-scoring Segment Pairs:这一行，将标志位设为1

	else{
	    next;
	}
	# FLAG=0的状态，就是寻找查询信息和匹配结果部分的标题
	# 如果不是上面两种情况，继续下一次循环，而一旦找到了匹配结果部分的标题，就将标志位设为1，跳出当前循环

    }
    else{
	if(/^([\w\.\-]+)\s+.+\s+([0-9]+)\s+([0-9e\-\.]+)\s+[0-9]+$/){
	    $hit = $1;
	    $score = $2;
	    $p_value = $3;
	    last;
	}
	else{
	    next;
	}
    }
	# FLAG=1的状态，就是寻找匹配结果部分的每一行，其实就是匹配到了Sequences producing High-scoring Segment Pairs:这一行之后的部分
	# 匹配到了这一行，那就可以接着循环每一行，直到提取标识符，得分和P值，保存到$hit,$score,$p_value中
	# 如果没有匹配到，就继续下一次循环，因为flag没有改变，所以还是在匹配结果部分，也就是当前循环的目的
}

close BLASTOUT;
# 关闭blast输出文件句柄BLASTOUT

print "Best hit to $query is: $hit, with score $score, P-value $p_value.\n";
# 最后，将最佳匹配的结果输出到屏幕

exit;
# 脚本执行结束

