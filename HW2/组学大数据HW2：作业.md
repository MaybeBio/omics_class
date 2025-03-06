先给出回答：  
Q1：  
![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741186129884-b2158d44-c330-4361-8c97-3d9998110834.png)

首先S-W的ppt上的这个前提我们照抄

然后初始+递推如下

![](https://cdn.nlark.com/yuque/0/2025/jpeg/33753661/1741188725008-1c061207-d3a2-4fb8-9ea0-a072892167dc.jpeg)



我是举了个简单的例子，从结果倒推方法的

![](https://cdn.nlark.com/yuque/0/2025/jpeg/33753661/1741188473939-f8d076c8-a0d9-4287-8000-20f5e9b83956.jpeg)



Q2：

```python
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


```





**下面是解题思路过程：！！！！！！！！！！！！！！！**





1，序列组装背景下的序列比对算法设计问题：  
来自chr同一区域的重叠测序片段reads x和y，只有中间重叠，即x的后缀和y的前缀重叠overlap；

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741102453309-bde6b2fb-97f5-41d6-b4f4-8babb1445ce0.png)

**<font style="color:#DF2A3F;background-color:#FBDE28;">这个图画的应该是X1_M，Y1_N，然后X的后缀Xi_M和Y的前缀Y1_j是overlap也就是mapping上的</font>**。

最优对齐：

x的后缀和y的前缀是局部比对，要求严格，x后缀的延长和y的其余部分是全都是indel比对（gap）。

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741102672372-2ed4ce85-5a11-417f-b54a-b2718b3e472e.png)

也就是对于x的前缀和y的后缀，也就是不需要比对上的地方，我们罚分低一点，这样我们的gap就会连续一点，不会被中间需要严格比对的部分所分隔开；

对于x的后缀和y的前缀部分，我们需要正常的罚分，正常比对，而且此处的罚分（indel也就是gap肯定得比两端的高，不然两端gap罚分也高的话，总体追求低罚分综合低，就会导致中间gap的补偿增多）。

**<font style="color:#DF2A3F;background-color:#FBDE28;">意思就是对于gap，我们要区分是两端的，还是中间比对部分的：  
</font>****<font style="color:#DF2A3F;background-color:#FBDE28;">如果是两端的，我们设置罚分低一点，中间设置高一点：  
</font>****<font style="color:#DF2A3F;background-color:#FBDE28;">因为同样的总和分数，gap肯定是倾向于在低罚分区域引入，也就是说低罚分会导致gap数目引入增多，而高罚分会导致gap数目引入减少；两端引入gap会多点，中间引入gap会少一点。</font>**

我们需要的是中间比对部分最好不要被gap打断连续性，所以要尽可能将gap向两端overhang区域引入（在同样总和分数前提下）

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741102873569-9545d494-db7c-4745-8a87-fb31ab73f02c.png)

我们的罚分矩阵（打分矩阵）设计的理念见上：  
match：+1

mismatch：-3

indel/gap：-10（normal），至于overhang部分需要再考虑（罚分得低一点，理由见上）；

然后因为前面已经说了，局部比对中两端的gap是不计入罚分的，或者说是计入为0，也就是认为这两部分实际上是不参与到比对中的，所以不考虑罚分如何，正好0也比-10的gap高，所以我们如果采用了。生物学意义上也好理解，中间突变如果类似于DNA三联体会引起很多进化上的麻烦，如果是两端突变肯定对进化损失或者说是伤害小一点。



总之：罚分矩阵

match：+1

mismatch：-3

indel/gap：-10（normal，aligned part）

0 （overhang）



上面就是我的初始想法，然后我其实觉得应该就在S-W上面改动点什么就可以了，但是一直没想到什么方法；

后来觉得倒不如凑个简单的例子来看看，从结果上如何倒推我想要的后缀比对前缀的实现路径；

所以我就凑了ATCG vs CGTA，

例子很简单，我就想看看，我到底在这个过程中应该如何设置罚分，才能够让我的路径回溯，或者说每次记录局部最优得分的来源，然后连成的路径就是我想要的后缀比对前缀；

我的想法其实很简单，因为要让第2条序列的CG部分比对上，也就是意味着第2条序列的前缀要一直是gap，也就是要从矩阵竖向的方向进行

我的想法很简单，因为第2条序列的前缀部分不能在一开始比对上去，所以我得加罚分，也就是惩罚这条路径，既然竖向是我倾向走的，那就横向加罚分。

![](https://cdn.nlark.com/yuque/0/2025/jpeg/33753661/1741188523334-a0f7af5e-d0a8-461e-9783-8ddc83a320a9.jpeg)

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741164469126-f10ea234-ad66-4c28-8110-7c79e3309379.png)

仿照局部比对的公式：  
![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741186126666-5334447c-78e8-4efc-9612-d8869960e744.png)

![](https://cdn.nlark.com/yuque/0/2025/jpeg/33753661/1741188752559-aad5fd36-351a-4901-937e-10b890a1871d.jpeg)





2，

你是生物信息学小组的新人，他们刚刚决定将信息学管道中的所有内容从WU-BLAST搜索转换Smith/Waterman搜索。幸运的是，你注意到ssearch（Bill Pearson的FASTA包的一部分），一个Smith/Waterman局部比对算法的鲁棒性实现，已经安装在我们的课程服务器上供你使用（man查看command手册）。

您还有一个遗留Perl脚本，它接受WU-BLAST输出文件并对其进行解析，以查找查询序列的名称，以及得分最高的hit的名称、得分和p值。脚本的源代码在这里（/lustre/share/class/BIO8402/hw2/blastparser.pl）。

WU-BLAST输出的一个例子如下（/lustre/share/class/BIO8402/hw2/blast.out）。

将此脚本复制到名为blastparser.pl和blast的文件中。

并使解析器作为程序可执行（chmod +x blastparser.pl）。

当您在示例输出文件上运行脚本时，它会生成如下的输出摘要行：

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741165473117-c14620a3-431c-4866-85db-d56c93c6ffef.png)

您的任务是修改脚本以对ssearch输出文件执行相同的工作。

这里是一个具有相同查询的ssearch输出示例（/lustre/share/class/BIO8402/hw2/ search.out）。

解析文件以获得查询名称，以及top hit的名称、分数和e值。

让脚本打印出与BLAST解析器脚本类似的摘要行，以显示此信息

然后这两个文件是怎么得出来的，粘贴了一些运行命令：  
![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741165847458-b426eb53-8e28-4fec-b01c-82ce74ad601c.png)





——》总之任务就是：

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741165409585-66bdbefe-47cb-4a84-b276-b8e9156d5bb3.png)

WU-BLAST算法输出文件：

blast.out输入——》blastparser.pl脚本处理——》输出summary lines

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741183847860-773dcb56-1610-4f32-beff-fe6dfe654bbf.png)

现在手头上有另外一个输入文件

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741165713372-51ce95c3-2bf1-4edf-8452-d4c626c9f011.png)

ssearch.out输入——》修改原先的脚本——》同样要输出summary lines



实际上就是这么一小条序列

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741183676358-712e3afa-00b8-4d2a-b5c3-566110586ab0.png)

使用 fasta 软件包中的 ssearch36 工具，将 u1_human.fa 文件中的蛋白质序列与 ws_215.protein.fa 文件中的蛋白质序列进行比对，并将比对结果保存到 ssearch.out 文件中；

我们得到的结果也只是针对这个蛋白的分析

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741183752399-3c875fd4-aa22-40fc-94af-778cf5e506f7.png)

按理来说得到的也应该是这个序列：也就是K08D10.3

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741183886449-7306e418-194f-47a2-97f8-60a1a59ebe26.png)



修改部分其实很简单，就是文本处理，其使用三剑客awk、sed、grep写shell脚本就能处理；

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741185219317-ffde053c-b70c-4c90-9156-f195e1ba8904.png)

除了我自己的主机，

在超算上同样执行成功：  
![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741185364939-626abd4b-123c-4a76-b749-022503afeb10.png)

**<font style="color:#DF2A3F;background-color:#FBDE28;">下面是我修改之后的perl脚本</font>**

```python
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


```







**<font style="color:#DF2A3F;background-color:#FBDE28;">注意：以下部分仅仅是对提供的脚本的拆解注释，依据google搜索自行标注</font>**

**<font style="color:#DF2A3F;background-color:#FBDE28;">（此处展示仅仅是为了表明作业中的脚本是依据示例脚本拆解注释之后手动修改的）</font>**

```python
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

```



![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741172078048-844e65ef-3303-40b4-b1a7-fb8f95f5b4c4.png)

  


