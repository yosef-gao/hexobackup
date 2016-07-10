---
title: Linux shell program(2)
tags:
  - linux
  - shell
categories: Linux
author: yosef gao
date: 2016-06-12 14:48:12
---


这一部分主要总结的是shell如何处理用户的输入，包括命令行参数的处理，用户键盘输入的读取等。

<!--more-->

命令行参数
-----------
bash shell 会将一些称为位置参数(position parameter)的特殊变量分配给命令行输入的所有参数，这其中也包括程序名。位置参数变量是标准的数字：**$0是程序名**，$1是第一个参数，$2是第二个参数……${10}是第10个参数，依此类推。这里10和之后的参数是需要用`{}`引起来的。
输入命令行参数时，如果参数中间有空格，需要用`""`引起来，比如"Rich Blum"。

在读取程序名时有一个需要注意的地方，先看一个例子：
{% codeblock lang:bash %}
$ cat ./test3.sh 
#!/bin/bash

echo The command entered is: $0
$ 
$ ./test3.sh 
The command entered is: ./test3.sh
$
$ ../script/test3.sh 
The command entered is: ../script/test3.sh
{% endcodeblock %}
当传给$0变量的真实字符串是整个脚本的路径时，程序中就会使用整个路径，而不仅仅是程序名。为了避免这个问题，可以使用basename命令来处理，返回程序名而不包括路径。
{% codeblock lang:bash %}
$ cat test3b.sh 
#!/bin/bash

name=`basename $0`
echo The command entered is: $name
$ 
$ ./test3b.sh 
The command entered is: test3b.sh
$
$ ../script/test3b.sh 
The command entered is: test3b.sh
{% endcodeblock %}

参数的数量可以通过参数计数变量`$#`来读取。我们知道读取数组A内第5个上的元素可以使用${A[5]}。当使用`$#`变量来读取最后一个命令行参数变量的时候，稍微有点区别，使用方式如下：
{% codeblock lang:bash %}
$ cat test4.sh 
#!/bin/bash

params=$#
echo The last parameter is ${!# }
$
$ ./test4.sh 2 3 4 5 6
The last parameter is 6
{% endcodeblock %}

bash shell还提供了$\*和$@变量对所有参数的快速访问。这两个都能够在单个变量重存储所有的命令行参数。其中$\*变量会将命令行上提供的所有参数当作单个单词保存，而$@变量会将命令行上所提供的所有参数当作同一个字符串中的多个独立的单词，即$@为一个数组，数组的每一个元素为命令行上的一个参数。

移动变量
---------
bash shell 工具链中另一个工具是shift命令。在使用shift命令时，默认情况下它会将每个参数变量减一。所以，变量$3的值会移动$2，变量$2的值会一道$1，而变量$1的值会被删除，但是$0的值，也就是程序名不会改变。
这是遍历命令行参数的一个方法，可以只操作第一个参数，移动参数，然后继续操作第一个参数。下面是一个例子：
{% codeblock lang:bash %}
$ cat test5.sh 
#!/bin/bash

count=1
while [ -n "$1" ]; do
    echo "Parameter #$count = $1"
    count=$[ $count + 1 ]
    shift
done
$
$ ./test5.sh rich barbara katie jessica
Parameter #1 = rich
Parameter #2 = barbara
Parameter #3 = katie
Parameter #4 = jessica
$
{% endcodeblock %}

处理选项
--------
这里仅摘录一种比较高级的选项处理方式：getopts命令。每次调用getopts命令时，它只处理一个命令行上检测到的参数。处理完所有的参数后，它会退出并返回一个大于零的退出状态码。getopts命令的格式如下：
getopts opstring variable
getopts命令会用到两个环境变量。如果选项需要跟一个参数值，OPTARG环境变量就会保存这个值。OPTIND环境变量保存了参数列表中getopts正在处理的参数位置。
下面是一个简单的使用getopts的例子：
{% codeblock lang:bash %}
$ cat test6.sh 
#!/bin/bash

while getopts :ab:c opt; do
    case "$opt" in
        a) echo "Found the -a option";;
        b) echo "Found the -b option, with value $OPTARG";;
        c) echo "Found the -c option, with index $OPTIND";;
        *) echo "Unknow option: $opt";;
    esac
done
$ 
$ ./test6.sh -ab test1 -c
Found the -a option
Found the -b option, with value test1
Found the -c option, with index 4
{% endcodeblock %}

获取用户输入
-----------
read命令接受从标准输入（键盘）或另一个文件描述符的输入。在收到出入后，read命令会将数据放进一个标准变量。
{% codeblock lang:bash %}
$ cat test7.sh 
#!/bin/bash

read -p "Please enter your age: " age
days=$[ $age * 365 ]
echo "that makes you over $days days old!"
$ 
$ ./test7.sh 
Please enter your age: 24
that makes you over 8760 days old!
{% endcodeblock %}
其中-p选项允许你直接在read命令行制定提示符。注意，read命令会为提示符输入的所有数据分配一个变量，或者你也可以指定多个变量。输入的每个数据值都会分配给表中的下一个变量。如果变量表在数据之前用完了，剩下的数据就都会分配给最后一个变量。
你可以在read命令行中不指定变量。如果那么做了，read命令会将它收到的任何数据都放进特殊环境变量REPLY中。

read命令可以使用-t选项来指定输入等待的秒数。当计时器过期后，read命令会返回一个非零退出码：
{% codeblock lang:bash %}
$ cat test7.sh 
#!/bin/bash

if read -t 5 -p "Please enter your age: " age; then
    days=$[ $age * 365 ]
    echo "that makes you over $days days old!"
else
    echo
    echo "Sorry, too slow!"
fi

$ ./test7.sh 
Please enter your age: 
Sorry, too slow!
{% endcodeblock %}

有时需要读取用户的输入，但不想输入出现在屏幕上，可以使用-s选项阻止将传给read命令的数据现实在显示器上：
{% codeblock lang:bash %}
$ cat test8.sh 
#!/bin/bash

read -s -p "Enter your password: " pass
echo
echo "Is your password \"$pass\" ?"
$ 

$ ./test8.sh 
Enter your password: 
Is your password "123456" ?
{% endcodeblock %}

从文件中读取数据，每次调用read命令会从文件中读取一行文本。当文件中再没有内容时，read命令会退出并返回非零状态码。
其中最难的部分是将文件中的数据传给read命令，最常见的方法是将文件运行cat命令后的输出通过管道直接传给含有read命令的while命令，以下是一个例子：
{% codeblock lang:bash %}
$ cat test9.sh 
#!/bin/bash

count=1
cat test | while read line; do
    echo "Line $count: $line"
    count=$[ $count + 1 ]
done
echo "Finished processing the file"
$
$ ./test9.sh 
Line 1: The quick brown dog jumps over the lazy fox.
Line 2: This is a test, this is only a test. 
Line 3: O Remeo, Romeo! Wherefore art thou Remeo?
Finished processing the file
$ 
{% endcodeblock %}

数据流重定向(redirect)
-------------
数据流重定向可以将standard output(stdout)和standard error output(stderr)分别传送到其他的文件或设备去，其中传送所用的特殊字符如下所示：
1. 标准输入(stdin)：代码为0,使用<或<<；
2. 标准输出(stdout)：代码为1,使用>或>>;
3. 标准错误输出(stderr)：代码为2,使用2>或2>>。

其中>(<)和>>(<<)的区别如下,注意数字和符号之间没有空格：
- 1>：以覆盖的方法将正确的数据输出到指定的文件或设备上(不存在则创建)；
- 1>>：以累加的方法将正确的数据输出到指定的文件或设备上；
- 2>：以覆盖的方法将错误的数据输出到指定的文件或设备上；
- 2>>：以累加的方法将错误的数据输出到指定的文件或设备上；
- <：将原本需要由键盘输入的数据改由文件内容来替代；
- <<：内联输入重定向，代表结束输入的意思，具体见下面例子。

如果需要忽略输出的内容，可以使用如下方法，可以把/dev/null理解为一个黑洞设备：
{% codeblock lang:bash %}
find /home -name .bashrc 2> /dev/null
{% endcodeblock %}

如果需要把正穷与错误数据都写入同一个文件中，可以使用如下方法
{% codeblock lang:bash %}
find /home -name .bashrc > list 2> list # 错误的方法，会造成数据交替写入，次序混乱
find /home -name .bashrc > list 2>&1 	# 正确
find /home -name .bashrc &> list	# 正确
{% endcodeblock %}
