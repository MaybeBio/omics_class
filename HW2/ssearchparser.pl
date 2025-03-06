#!/usr/bin/perl -w 

use strict;

my ($ssearch_out) = @ARGV;

my $usage = "This script is to get the best hit from ssearch output file with 1 input sequence.
usage: $0 <ssearch_output_file>
";

die $usage if @ARGV<1;

open(SSEARCHOUT,$ssearch_out)||die("open $ssearch_out error!\n");

my $query = "";  
my $s_w = "";
my $bits = "";	
my $e_value = ""; 
my $hit = "";	
my $flag = 0;	
while(<SSEARCHOUT>){
    chomp;
    if($flag == 0){
	if(/^Query:\s*(\w+)/){
	    $query = $1;
	}
	# 匹配Query:开头的行，提取查询序列的标识符，保存到$query中
	# 其实就是捕获Query=开头的行中的除开空格部分的单词字符，第1个捕获组

	elsif(/^The best scores are:/){
	    $flag = 1;
	}
	# 匹配到The best scores are:这一行，将标志位设为1

	else{
	    next;
	}
	# FLAG=0的状态，就是寻找查询信息和匹配结果部分的标题
	# 如果不是上面两种情况，继续下一次循环，而一旦找到了匹配结果部分的标题，就将标志位设为1，跳出当前循环

    }
    else{
	if(/^([\w\.\-]+)\s+.+\s+([0-9]+)\s+([0-9\.]+)\s+([0-9e\-\.]+)+$/){
	    $hit = $1;
		$s_w = $2;
		$bits = $3;
		$e_value = $4;
	    last;
	}
	else{
	    next;
	}
    }
	# FLAG=1的状态，就是寻找匹配结果部分的每一行，其实就是匹配到了The best scores are:这一行之后的部分
	# 匹配到了这一行，那就可以接着循环每一行，直到提取标识符，得分和e值，保存到对应变量中
	# 如果没有匹配到，就继续下一次循环，因为flag没有改变，所以还是在匹配结果部分，也就是当前循环的目的
}

close SSEARCHOUT;
# 关闭blast输出文件句柄BLASTOUT

print "Best hit to $query is: $hit, with s-w $s_w, bites $bits, e-value $e_value.\n";
# 最后，将最佳匹配的结果输出到屏幕

exit;

