---
title: Linux shell program(3)
tags:
  - linux
  - shell
categories: Linux
date: 2016-06-13 15:27:34
---


在shell中有一段代码需要重复使用时，就可以用函数来代替。
<!--more-->

函数创建与使用
-------------
有两种格式可以用来在bash shell脚本中创建函数。第一种格式采用关键字function，后跟分配给该代码块的函数名：
{% codeblock lang:bash %}
function name {
    commands
}
{% endcodeblock %}
name属性定义了赋予函数的唯一名称。脚本中定义的每个函数都必须是唯一的名称。
bash shell脚本中定义函数的第二种格式跟在其他语言中定义函数很像：
{% codeblock lang:bash %}
name() {
    commands
}
{% endcodeblock %}
函数名后的圆括号为空，表明正在定义的是一个函数。

用在脚本中使用函数，在行上指定函数名就行了，跟使用其他shell命令一样：
{% codeblock lang:bash %}
$ cat test10.sh 
#!/bin/bash

function func1 {
    echo "This is an example of a function"
}

count=1
while [ $count -le 5 ]; do
    func1
    count=$[ $count + 1 ]
done

echo "This is the end of the loop"
func1
echo "Now this is the end of the srcipt"
$
$ ./test10.sh 
This is an example of a function
This is an example of a function
This is an example of a function
This is an example of a function
This is an example of a function
This is the end of the loop
This is an example of a function
Now this is the end of the srcipt
{% endcodeblock %}

函数的返回值
-------------
bash shell会把函数当作小型脚本，运行结束时会返回一个退出状态码。有3中不同的方法来为函数生成退出状态码。

**1. 默认退出状态码**
默认情况下，函数的退出状态码是函数中最后一条命令返回的退出码。在函数执行结束后，你可以用标准的$?变量来决定函数的退出状态码：
{% codeblock lang:bash %}
$ cat test11.sh 
#!/bin/bash

func1() {
    ls -l badfile
    echo "This was a test of a bad command"
}

echo "testing the function:"
func1
echo "The exit status is: $?"
$
$ ./test11.sh 
testing the function:
ls: 无法访问badfile: 没有那个文件或目录
This was a test of a bad command
The exit status is: 0
$
{% endcodeblock %}
从上述代码可以看到，由于函数以成功运行的echo语句结尾，函数的退出状态码就是0,尽管函数中有一条命令没有运行成功。使用函数的默认退出状态码是很危险的。

**2. 使用return命令**
bash shell使用return命令来退出函数并返回特定的退出状态码。return命令允许指定一个整数值来定义函数的退出状态码：
{% codeblock lang:bash %}
$ cat test12.sh 
#!/bin/bash

function db1 {
    read -p "Enter a value: " value
    echo "doubling the value"
    return $[ $value * 2 ]
}

db1
echo "The new value is $?"
$ ./test12.sh 
Enter a value: 12
doubling the value
The new value is 24
$ 
{% endcodeblock %}
但当使用这种方法从函数中返回值时，要记住下面两点：
- 函数一结束就取返回值
- 退出状态码必须在0~255之间。

如果在用$?变量提取函数返回值之前执行了其他命令，函数的返回值就可能会丢失。

**3. 使用函数输出**
正如同可以将命令的输出保存在shell变量中一样，也可以将函数的输出保存到shell变量中。可以用这种技术来获得任何类型的函数输出，并将其保存到变量中：
{% codeblock lang:bash %}
$ cat test13.sh 
#!/bin/bash

function db1 {
    read -p "Enter a value: " value
    echo $[ $value * 2 ]
}

result=`db1`
echo "The new value is $result"
$ ./test13.sh 
Enter a value: 200
The new value is 400
$ 
{% endcodeblock %}
本示例演示了一个小技巧。你会注意到db1函数输出了两条消息。read命令输出了一条简短的消息来向用户询问输入值。bash shell脚本会聪明地不将它作为STDOUT输出的一部分，并且忽略掉它。如果你用echo语句生成这条消息来向用户查询，则shell命令会将其与输出值一起读进变量中。
通过这种方法，你还可以返回浮点值和字符串值。这让它非常适合返回函数值。

函数中使用变量
----------------
函数可以使用标准的参数环境变量来代表命令行上传给函数的参数。例如，函数名会在$0变量中定义，函数命令行上的任何参数都会通过$1,$2等定义。也可以用特殊变量$#来判断传给函数的参数数目。
在脚本中指定函数时，必须将参数和函数放在同一行：
{% codeblock lang:bash %}
$ cat test14.sh 
#!/bin/bash

function addem {
    if [ $# -eq 0 ] || [ $# -gt 2 ]; then
        echo -1
    elif [ $# -eq 1 ]; then
        echo $[ $1 + $1 ]
    else
        echo $[ $1 + $2 ]
    fi
}

echo -n "Adding 10 and 15: "
value=`addem 10 15`
echo $value
echo -n "Let's try adding just one numbers: "
value=`addem 10`
echo $value
echo -n "Now let's try adding no numbers: "
value=`addem`
echo $value
echo -n "Finally, let't try adding three numbers: "
value=`addem 10 15 20`
echo $value
$
$ ./test14.sh 
Adding 10 and 15: 25
Let's try adding just one numbers: 20
Now let's try adding no numbers: -1
Finally, let't try adding three numbers: -1
$ 
{% endcodeblock %}

函数中的全局变量与局部变量
--------------------------
**全局变量**是在shell脚本中任何地方都有效的变量。默认情况下，你在脚本中定义的任何变量都是全局变量。在函数外定义的变量可在函数内正常访问。
不用在函数中使用全局变量，函数每部使用的任何变量都可以被声明成**局部变量**。要那么做时，只要在变量声明的前面加上local关键字就可以了。
下面是全局变量与局部变量的例子：
{% codeblock lang:bash %}
$ cat test15.sh 
#!/bin/bash

function func1 {
    local temp=$[ $value + 5 ]
    temp=$[ $temp * 2 ]
    value=$[ $value + 5 ]
}

temp=4
value=6

echo "Before func1, temp is $temp, value is $value"
func1
echo "After func1, temp is $temp, value is $value"
$ 
$ ./test15.sh 
Before func1, temp is 4, value is 6
After func1, temp is 4, value is 11
$ 
{% endcodeblock %}
从上面的例子可以看出，在函数内部声明的局部变量temp会**覆盖**全局变量temp，至于在声明了局部变量temp之后如何再引用全局变量变量temp，我目前还不知道。

函数与数组
------------
向函数传递数组变量以及从函数返回数组稍微有点麻烦。首先是传递数组变量，你必须将该数组变量的值分解成单个值，然后将这些值作为函数参数使用，在函数内部，你可以将所有的参数重组到新的数组变量中;从函数里向shell脚本传回数组变量也用类似的方式。函数用echo语句来正确顺序输出单个数组值，然后脚本再将它们重新放进一个新的数组中变量中：
{% codeblock lang:bash %}
$ cat test16.sh 
#!/bin/bash

function testit {
    local newarray
    newarray=(`echo "$@"`)
    for (( i = 0; i < $#; i++ ))
    {
        newarray[$i]=$[ ${newarray[$i]} + 1 ]
    }
    echo ${newarray[*]}
}

myarray=(1 2 3 4 5)
echo "The original array is ${myarray[*]}"
arg1=`echo ${myarray[*]}`
result=(`testit $arg1`)
echo "The new array is: ${result[*]}"
$ ./test16.sh 
The original array is 1 2 3 4 5
The new array is: 2 3 4 5 6
$ 
{% endcodeblock %}

函数递归
---------
bash shell的函数递归与其他语言类似，下面举一个阶乘递归的例子：
{% codeblock lang:bash %}
$ cat test17.sh 
#!/bin/bash

function factorial {
    if [ $1 -eq 1 ]; then
        echo 1
    else
        local temp=$[ $1 - 1 ]
        local result=`factorial $temp`
        echo $[ $result * $1 ]
    fi
}

read -p "Enter value: " value
result=`factorial $value`
echo "The factorial of $value is: $result"
$ 
$ ./test17.sh 
Enter value: 4
The factorial of 4 is: 24
{% endcodeblock %}
