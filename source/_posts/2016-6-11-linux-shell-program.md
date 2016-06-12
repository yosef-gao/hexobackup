---
title: Linux shell program(1)
tags:
  - shell
  - linux
categories: Linux
author: yosef gao
date: 2016-06-11 19:32:45
---


掌握linux shell 编程，可以用简单的脚本来执行大量简单的重复任务，定时任务，是使用linux必备的技能之一，本文简单总结linux shell编程的一些要点和技巧。

<!--more-->

退出状态码
----------
Linux提供了$?专属变量来保存上个执行的命令的退出状态码。你必须在你要查看的命令之后马上查看或使用$?变量。它的值会变成shell中执行的最后一条命令的退出状态码。
按照惯例，一个成功结束的命令的退出状态码是0.如果一个命令结束时有错误，退出状态码就会有一个正数值：
{% codeblock lang:bash %}
~$ asdfg
程序“asdfg”尚未安装。 您可以使用以下命令安装：
sudo apt-get install aoeui
~$ echo $?
127
~$ 
{% endcodeblock %}

Linux错误退出的状态码没有什么标准惯例。但有一些可用的参考，如下表所示：

| 状 态 码	| 描  述       		|
| :--------	|:---------------------	|
| 0           	| 命令成功结束 		|
| 1         	| 通用未知错误 		|
| 2         	| 误用shell命令		|
| 126         	| 命令不可执行		|
| 127         	| 没找到命令		|
| 128         	| 无效退出参数		|
| 128+x        	| Linux信号x的严重错误	|
| 130        	| 命令通过Ctrl+C终止	|
| 255        	| 退出状态码越界	|

命令exit允许你指定一个退出状态码，但只能之0~255之间，否则shell会通过模运算得到这个范围之间的结果。

if-then 及其相关语句
----------------------
最基本的if-then语句格式如下：
{% codeblock lang:bash %}
if command
then
	commands
fi
{% endcodeblock %}
不过我更喜欢下面这种格式：
{% codeblock lang:bash %}
if command; then
    commands
fi
{% endcodeblock %}

test命令提供了在if-then语句中测试不同条件的途径，格式为：
test condition
bash shell 提供了另一种在if-then语句中声明test命令的方法：
{% codeblock lang:bash %}
if [ condition ]; then
    commands
fi
{% endcodeblock %}
这个要注意**左括号右侧与右括号左侧各加一个空格**，否则会报错。

test命令提供三种3类条件的判断：
- 数值比较
- 字符串比较
- 文件比较

**1. 数值比较**
下表列出了测试两个值时可用的条件参数。

| 比   较	| 描    述     		|
| :--------	|:---------------------	|
| n1 -eq n2    	| 检查n1是否与n2相等	|
| n1 -ge n2   	| 检查n1是否大于等于n2	|
| n1 -gt n2 	| 检查n1是否大于n2	|
| n1 -le n2   	| 检查n1是否小于等于n2	|
| n1 -lt n2   	| 检查n1是否小于n2	|
| n1 -ne n2   	| 检查n1是否不等于n2	|

**2. 字符串比较**
下表列出了可用来比较两个字符串值的函数。

| 比   较	| 描    述     		|
| :--------	|:---------------------	|
| str1 = str2  	| 检查str1是否和str2相同 |
| str1 != str2 	| 检查str1是否和str2不同 |
| str1 < str2 	| 检查str1是比str2小	|
| str1 > str2  	| 检查str1是比str2大	|
| -n str1   	| 检查str1的长度是否非0	|
| -z str1 	| 检查str1的长度是否为0	|

这里要注意`>`,`<`符号必须转义`\>`,`\<`。另一点，这里的比较大写字母是小于小写字母的。

**3. 文件比较**
下表列出了可用的文件比较函数。

| 比   较		| 描    述     				|
| :--------		|:---------------------			|
| -d file 	 	| 检查file是否存在并是一个目录		|
| -e file 		| 检查file是否存在	 		|
| -f file 		| 检查file是否存在并是一个文件		|
| -r file 	 	| 检查file是否存在并可读			|
| -s file 	  	| 检查file是否存在并非空			|
| -w file 		| 检查file是否存在并可写			|
| -x file 		| 检检查file是否存在并可执行		|
| -O file 		| 检查file是否存在并属当前用户所有	|
| -G file 		| 检查file是否存在并且默认组与当前用户相同|
| file1 -nt file2	| 检查file1是否比file2新		|
| file1 -ot file2	| 检查file1是否比file2旧		|

if-then 可以使用(( expression )) 来将高级数学表达式放入比较中。在元括号中表达式里的大于号不需要转义。
{% codeblock lang:bash %}
val1=10
if (( $val1 **2 > 90 )); then
    (( val2 = $val1 ** 2 ))
    echo "The square of $val1 is $val2"
fi
{% endcodeblock %}

双方括号命令提供了针对字符串比较的高级特征。[[ expression ]]
双方括号里的expression使用了test命令中采用的标准字符串进行比较，同时也提供了test没有的匹配模式(pattern matching)特性。
{% codeblock lang:bash %}
if [[ $USER == r* ]]; then
    echo "Hello $USER"
else
    echo "Sorry. I do not know you."
fi
{% endcodeblock %}

case 命令
---------
简单语法如下：
{% codeblock lang:bash %}
case variable in
pattern1 | pattern2) commands1;;
pattern3 commands2;;
*) default commands;;
esac
{% endcodeblock %}
*号会捕获所有跟所有列出的模式都不匹配的值。

一个简单的例子如下：
{% codeblock lang:bash %}
case $USER in
rich | barbara) 
    echo "Welcome, $USER"
    echo "Please enjoy your visit";;
test)
    echo "Special testing account";;
jessica)
    echo "Do not forget to log out when you're done";;
*)
    echo "Sorry, you are not allowed here";;
esca
{% endcodeblock %}

循环语句
----------
**1. for 命令**
基本语法：
{% codeblock lang:bash %}
for var in list
do
    commands
done

for var in list; do
    commands
done
{% endcodeblock %}

bash shell 也支持c语言风格的for命令：
{% codeblock lang::bash %}
for (( a=1; a < 10; a++ ))
{% endcodeblock %}
其中有一些事情没有遵循标准的bash shell for 命令：
- 给变量赋值可以有空格
- 条件中的变量不以美元符开头
- 迭代过程中的算是未用expr命令格式

有一个特殊的环境变量叫IFS(internal field sepearator)，称为内部字段分隔符。IFS环境变量定义了bash shell用作字段分隔符的一系列字符。默认情况下，bash shell会将下列字符当作字段分隔符：
- 空格
- 制表符
- 换行符
如果bash shell在数据中看到了这些字符中的任意一个，它就会假定你在列表中开始了一个新的数据段。在处理可能含有空格的数据(比如文件名)时，这会非常麻烦。
要解决这个问题，你可以在shell脚本中临时更改IFS环境变量的值来限制一下被bash shell当作字段分隔符的字符。一个可以参考的简单实践是在改变IFS之前保存原来IFS的值，之后再恢复它。
这种技术可以这样编程：
{% codeblock lang:bash %}
IFS.OLD=$IFS
IFS=$'\n'
<use the new IFS value in code>
IFS=$IFS.OLD
{% endcodeblock %}
如果你要指定多个IFS字符，只要将他们在赋值行串起来就行：
IFS=$'\n:;"'

**2. while 命令**
while命令的格式是：
{% codeblock lang:bash %}
while test command
do 
    other commands
done

while test commands; do
    other commnads
done
{% endcodeblock %}

**3. until 命令**
until命令的格式是：
{% codeblock lang:bash %}
until test commands
do 
    other commands
done 

until test commands; do
    other commands
done
{% endcodeblock %}
until命令要求你指定一个通常输出非零退出状态码的测试命令。

**4. break，continue命令**
break命令可以退出循环。在处理多个循环时，break命令会自动终止你所在最里面的循环。brea命令接受单个命令行参数值：
break n
用来指明要跳出的循环的层数。

最后，在shell脚本中，可以在done命令之后添加一个处理命令：
done > output.txt
将循环命令的结果和重定向到文件output.txt中。
