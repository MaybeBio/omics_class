我手头有一个脚本，用于从blastp序列比对的结果文件中，进行文本处理，

获取序列比对最优的hit记录

```python
#!/usr/bin/perl -w
use strict;

my ($blast_out) = @ARGV;
my $usage = "This script is to get the best hit from blast output file with 1 input sequence.
usage: $0 <blast_output_file>
";
die $usage if @ARGV<1;

open(BLASTOUT,$blast_out)||die("open $blast_out error!\n");

my $query = "";
my $score = "";
my $p_value = "";
my $hit = "";
my $flag = 0;
while(<BLASTOUT>){
    chomp;
    if($flag == 0){
	if(/^Query=\s*(\w+)/){
	    $query = $1;
	}
	elsif(/^Sequences producing High-scoring Segment Pairs:/){
	    $flag = 1;
	}
	else{
	    next;
	}
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
}

close BLASTOUT;

print "Best hit to $query is: $hit, with score $score, P-value $p_value.\n";

exit;

```

然后我们逐行解读：  
1，表头的一些注释部分

```python
#!/usr/bin/perl -w 

# 表明这是一个perl脚本，-w表示打开警告
# 参考https://www.runoob.com/perl/perl-environment.html

use strict;
# use strict表示使用严格模式，这样可以避免一些不规范的写法
```

2，然后是输入以及输出文件的一些准备以及注释：

我们可以使用一个参考脚本来测试一下

```python
#!/usr/bin/perl -w
use strict;

# 测试不同的参数获取方式
print "命令行参数：@ARGV\n\n";

# 方式1：列表赋值 - 获取第一个元素
my ($var1) = @ARGV;
print "my (\$var1) = \@ARGV 结果：\n";
print "\$var1 = '$var1'\n\n";

# 方式2：标量赋值 - 获取数组长度
my $var2 = @ARGV;
print "my \$var2 = \@ARGV 结果：\n";
print "\$var2 = '$var2'\n\n";

# 方式3：列表赋值 - 获取多个元素
my ($arg1, $arg2, $arg3) = @ARGV;
print "my (\$arg1, \$arg2, \$arg3) = \@ARGV 结果：\n";
print "\$arg1 = '", (defined $arg1 ? $arg1 : "未定义"), "'\n";
print "\$arg2 = '", (defined $arg2 ? $arg2 : "未定义"), "'\n";
print "\$arg3 = '", (defined $arg3 ? $arg3 : "未定义"), "'\n";
```

如果不提供参数的话，效果如下：

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741175483613-83533f62-4d02-4404-a75e-9d103a2453d9.png)

如果只提供一个参数：  
![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741175564088-21951192-b33b-4d97-b366-57bab17fdded.png)

如果提供两个参数的话：  
![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741175635618-7347a8a1-f99c-49a7-bd5b-10657d8bdfa8.png)

如果提供3个参数的话：  
![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741175598419-fa51825d-6e68-4c80-a4a8-6b8d3afcd14b.png)

——》综上，我们可以看到效果是：

my ($var1) = @ARGV

如果是加个括号的话，获取的是数组中第1个传入的参数

my $var2 = @ARGV

如果没有加括号的话，捕获的是数组的长度

my ($arg1, $arg2, $arg3) = @ARGV

如果是这样写的话，那么就可以访问数组的下标元素

——》所以综上

```python
my ($blast_out) = @ARGV;
# 类似于shell脚本中 outputfile=$1这种写法
# 传给脚本的命令行参数列表,参考https://www.runoob.com/perl/perl-special-variables.html
# 变量定义使用my关键字，生命期直到其所在的代码块结束或者文件的末尾
# 从 @ARGV 数组中取出第一个元素，并将其赋给 $blast_out，与my $blast_out = @ARGV不同，后者会被赋予数组长度也就是元素数量
# 与my ($arg1, $arg2, $arg3) = @ARGV;写法区分
```



3，还有1个是函数的帮助文档

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741175987897-bd9e7d9d-e681-453d-a545-66f7434acdff.png)



```python
#!/usr/bin/perl -w
use strict;

# 定义使用说明
my $usage = "这个脚本演示使用说明变量的用法。
用法: $0 <参数1> [参数2] ...
  参数1: 必需的第一个参数
  参数2: 可选的第二个参数
";

# 检查参数
if (@ARGV < 1) {
    die $usage;  # 如果参数不足，终止并显示使用说明
}

# 打印获取的参数
print "成功运行！\n";
print "您提供的第一个参数是: $ARGV[0]\n";

if (defined $ARGV[1]) {
    print "您提供的第二个参数是: $ARGV[1]\n";
}
```



主要问题: die 语句会立即终止脚本执行，所以 die 之后的 print("参数不足") 语句永远不会被执行；

逻辑顺序: 如果您想打印错误信息，应该先打印，然后再 die	

——》然后die usage的用法我们可以再仔细学习观察一下：

```python
#!/usr/bin/perl -w
use strict;

# 定义使用说明
my $usage = "当你看到这个信息的时候,表明你提供的参数有问题,你应该看看这个程序是怎么使用的！\n这个脚本该如何使用\n用法如下:\n $0 <参数1>" ;

if (@ARGV < 1)
{
    print("参数不足!\n");
    die $usage; 
}
else
{
    print "提供参数的个数为：", scalar(@ARGV), "\n";
}


```

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741176768643-10b482fb-459a-4711-846f-03b6905618a2.png)![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741176807534-e16c7026-ad54-491e-928f-d989aefc9021.png)



4，然后就是文件操作错误示范：  
从语法规范上讲：  
![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741177479611-eb7d1002-ca68-4b03-ab4b-8853cca2dba1.png)![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741177495484-6fb6b6d8-8558-4d5e-8ecb-77e3c611f9f8.png)![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741178499608-4dc05b5f-8717-4e74-aea3-9ce20b924044.png)![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741178530812-50274fa2-8225-4272-bfed-acefd99d344f.png)



此处提供方法：如何在perl中查看函数帮助文档

```python
# 查看特定函数文档
perldoc -f function_name
# 例如：
perldoc -f open
perldoc -f die

# 查看 Perl 操作符
perldoc perlop

# 查看特殊变量
perldoc perlvar  

# 查看内置函数列表
perldoc perlfunc
```

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741178637929-0bd4896e-3f15-473a-a803-f7b2d06e6b18.png)![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741178654078-525afddf-6af8-4c60-b792-611309623739.png)

此处涉及到perl中句柄的相关知识：  
![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741178731435-a9bd681c-2adc-40ca-9811-6e0466659bcc.png)![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741178746206-a1d143fe-a684-414f-8f7b-ae5956d72a79.png)![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741178755472-c356541d-6ed2-4239-b23f-7906baaac3b5.png)





5，然后就是函数中的编程部分：  
![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741179100388-d1380090-8478-4db4-971e-28a5a4892dbf.png)

从循环语句开始：  
![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741179279594-dbcc529b-3c23-4d3c-a9a1-51ec89e6b4f6.png)

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741180162271-4f48e427-7883-4378-9870-c05aa9e1b2a1.png)

然后就是正则表达式，/  /中间的部分

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741179409740-dcdb4a26-99e4-40f9-b96c-6113578a61ca.png)![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741179423003-bba6ae26-10a7-43e7-b686-05b0eea38329.png)

其实就是捕获Query=开头的行中的除开空格部分的单词字符

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741179497800-b6bddd46-5aa3-4465-9917-8ff5ec1988b5.png)

其实整个正则表达式的匹配和正则表达式中一个子串（也就是所谓的捕获组）概念，在我之前的博客awk的内置函数中的match出现过；

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741181381397-acb5cf78-d14f-472a-afcf-85546ccc11b1.png)

然后flag=1的部分的循环

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741181507206-71a7ab79-f517-4cfd-b45b-3bbf095769de.png)

这部分的正则表达式详解：  
![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741182186916-12ddeb50-053f-405d-a4d5-78c004582b0b.png)![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741182199051-b2aca633-1f0d-4259-9f8f-8676bebc94d9.png)![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741182213857-e8113fcf-b3a8-40a4-94b1-447a5ace7aef.png)![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741183525245-e326377e-f139-49c7-a37e-cb3d9ce5a722.png)



6，然后就是文件最后结尾的部分：  
![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741182341390-42bcfdd2-18b4-46d4-8626-587c0596f4ba.png)



——》

综上，总体就是：  
1个用于blastP输出结果的文本抓取脚本，其实完全可以使用awk或者说是shell来执行

```perl
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
my $score = ""; # 最佳匹配的得分
my $p_value = ""; # 最佳匹配的P值
my $hit = "";   # 最佳匹配的标识符
my $flag = 0;   # 标志位，用于判断是否到了匹配结果的部分
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



二，使用ssearch

```python
 /lustre/share/class/BIO8402/tools/fasta-36.2.6/bin/ssearch36 -q u1_human.fa /lustre/share/class/BIO8402/C.elegans/Proteome/ws_215.protein.fa > new.out
```

![](https://cdn.nlark.com/yuque/0/2025/png/33753661/1741183417233-bf58b187-36e8-4b02-8469-0ef52a03fe86.png)

现在我们改一下工具，我们使用fasta也就是S-W经典算法中的工具实现ssearch，来进行序列比对，

然后同样要求使用perl脚本进行提取记录实现。

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



——》其实最主要修改部分就是正则表达式那部分

