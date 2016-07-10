---
title: Linux资源查看
tags: linux
categories: Linux
author: yosef gao
date: 2016-07-10 15:25:32
---


本文根据鸟哥书，总结了一些linux下常用的资源查看命令及其用法。
<!--more-->

进程查看
--------
进程查看主要是3个命令，ps静态查看，top动态查看，pstree查阅程序书之间的关系。

**ps**:将某个时间点的进程运行情况选取下来
{% codeblock lang:bash %}
ps aux	# 查看系统所有的进程数据
ps -lA	# 也是能够查看所有系统的数据
ps axjf	# 连同部分进程树状态
参数：
-A：所有的进程均显示出来，与-e具有相同的作用；
-a：不与terminal有关的所有进程；
-u：有效用户相关的进程；
x：通常与a这个参数一起使用，可列出较完整的信息；
输出格式规划：
l：较长，较详细地将该PID的信息列出；
j：工作的格式；
-f：做一个更为完整的输出。
{% endcodeblock %}

根据鸟哥的建议，ps记两个不同的参数就可以了，一个是只能查阅自己bash程序的`ps -l`，一个则是可以查看所有系统运行的程序`ps aux`。
{% codeblock lang:bash %}
$ ps -l
F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
0 S  1000  4530  2891  0  80   0 -  2656 wait   pts/6    00:00:00 bash
0 R  1000  4742  4530  0  80   0 -  1603 -      pts/6    00:00:00 ps
{% endcodeblock %}
- F代表进程标志(process flags)，说明这个进程的权限
- S代表这个进程的状态(STAT)，主要状态有：
    - R(Running)：该进程正在运行中；
    - S(Sleep)：该进程正在睡眠状态(idle)，但可以被唤醒(signal)；
    - D：不可被唤醒的睡眠状态，通常这个进程可能在等待I/O的情况；
    - T：停止状态(stop)，可能实在工作控制(后台暂停)或除错(traced)状态；
    - Z：(Zombie)：“僵尸”状态，进程已经终止，但却无法被删除至内存外。
- UID/PID/PPID：顾名思义，此进程的UID，PID和PPID号码。
- C：代表CPU使用率，单位为百分比。
- PRI/NI：Priority/Nice的缩写，代表此进程被CPU所执行的优先级，数值越小代表该进程越快被CPU执行。
- ADDR/SZ/WCHAN：与内存有关，ADDR是kernal function，指出该进程在内存的哪个部分，如果是个running的进程，一般就会显示“-”。SZ代表此进程用掉多少内存，WCHAN表示目前进程是否运行中，同样若-表示正在运行中。
- TTY：登陆者的终端机位置，若为远程登陆则使用动态终端接口(pts/n)。
- TIME：是用掉的CPU时间，是此进程实际花费CPU运行的时间，而不是系统时间。
- CMD：command，造成此程序的触发进程的命令。

相对于ps是选取一个时间点的进程状态，**top**则可以持续检测进程运行的状态。
{% codeblock lang:bash %}
top [-d 数字] | top [-bnp]
参数：
-d：后面接秒数，表示整个进程界面更新的秒数。默认是5秒。
-b：以批次的方式执行top，还有更多的参数可以使用。(?)
-n：与-b搭配，意义是，需要进行几次top的输出结果。(?)
-p：指定某些PID来进行查看检测。
在top执行过程中可以使用按键命令：
?：显示在top当中可以输入的按键命令；
P：以CPU的使用资源排序显示；
M：以内存的使用资源排序显示；
N：以PID来排序；
T：由该进程使用的CPU时间累积(TIME+)排序；
k：给予某个PID一个信号(signal)；
r：给予某个PID重新定制一个nice值；
q：离开top软件的按键。
{% endcodeblock %}

**pstree**
{% codeblock lang:bash %}
pstree [-A|U] [-up]
参数：
-A：各进程树之间的连接以ASCII字符来连接；
-U：各进程树之间的连接以utf8码的字符来连接，**在某些终端接口下可能会有错误**；
-p：同时列出每个进程的PID；
-u：同时列出每个进程的所属帐号名称。
{% endcodeblock %}

**free**：查看内存使用情况
{% codeblock lang:bash %}
pstree [-b|-k|-m|-g] [-t]
参数：
-b：直接输入free时，显示的单位是KB，可以使用b(bytes),m(MB),k(KB),以及g(GB)来显示单位；
-t：在输出的最终结果中显示无力内存与swap的总量。
例如：
$ free -mk
             total       used       free     shared    buffers     cached
Mem:       2063808    1484128     579680       6188     138728     646624
-/+ buffers/cache:     698776    1365032
Swap:       976892          0     976892
{% endcodeblock %}


**uname**：查看系统与内核相关信息
{% codeblock lang:bash %}
uname [-asrmpi]
参数：
-a：所有系统相关的信息，包括下面的数据都会被列出来；
-s：系统内核名称；
-r：内核版本；
-m：本系统的硬件名称，例如i686或x86_64等；
-p：CPU类型，与-m类似，只是显示的是CPU的类型；
-i：硬件的平台(ix86)
例如
$ uname -a
Linux vuser-virtual-machine 3.13.0-32-generic #57-Ubuntu SMP Tue Jul 15 03:51:12 UTC 2014 i686 i686 i686 GNU/Linux
{% endcodeblock %}

**uptime**：查看系统启动时间与工作负载
这个命令显示目前已经开机多久时间，以及1,5,15分钟的平均负载(注意top也有这个)，*即uptime可以显示top界面的最上面一行*。
{% codeblock lang:bash %}
$ uptime
 14:54:47 up  4:06,  3 users,  load average: 0.20, 0.26, 0.23
{% endcodeblock %}

**netstat**：网络状态
这个命令通常用在网络监控方面。netstat的输出分为两大部分，分别是网络与系统自己的进程相关性部分。
{% codeblock lang:bash %}
$ netstat -[atunlp]
参数：
-a：将目前系统上所有的连接、监听、Socket数据都列出来；
-t：列出tcp网络数据包的数据；
-u：列出udp网络数据包的数据；
-n：不列出进程的服务名称，以端口号(port number)来显示；
-l：列出目前正在网络监听(listen)的服务；
-p：列出该网络服务的进程PID。
{% endcodeblock %}

**dmesg**：分析内核产生的信息
系统在开机的时候，内核会去检测系统的硬件。但是这些检测过程要不是没有显示在屏幕上，要么就是很快在屏幕上一闪而过。所有内核检测的信息，都会被记录到内存中的某个保护区段。dmesg这个命令能够将该区段的信息读出来。由于信息较多，可以配合“| more”来显示。

**vmstat**：检测系统资源变化
vmstat可以检测CPU/内存/磁盘输入输出状态等，下面是常见的参数说明：
{% codeblock lang:bash %}
vmstat [-a] [延迟[总计检测次数]] # CPU/内存等信息
vmstat [-fs]			# 内存相关
vmstat [-s 单位]		# 设置显示数据的单位
vmstat [-d]			# 与磁盘有关
vmstat [-p 分区]		# 与磁盘有关
{% endcodeblock %}
