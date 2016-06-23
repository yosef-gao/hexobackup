---
title: 从磁盘分区开始谈起
tags: linux
categories: Linux
author: yosef gao
date: 2016-06-23 15:38:43
---


想对linux下面关于磁盘的操作做一下总结，先从磁盘分区开始谈起好了……

<!--more-->

磁盘分区
--------
从逻辑上来看，磁盘的分区示意图如下图所示。
{% asset_img "1.png" "磁盘分区示意图" %}
上图中假设磁盘只有400个柱面，共分区成为4个分区。由于分区表就只有64KB的大小，最多只能容纳四个分区，这个四个分区被称为主(Primary)或扩展(Extended)分区。
总结起来就是:
- “分区”其实就是针对那个64KB的分区表进行设置。
- 硬盘默认的分区表仅能写入四组分区信息。
- 这四组分区信息称为主(Primary)或扩展(Extended)分区。
- 分区的最小单位为柱面(cylinder)。

显然我们平时见到的硬盘往往可以分成四个或四个以上的分区。在Windows/Linux下是通过扩展分区来实现的。扩展分区的想法是：既然第一个扇区所在的分区表只能记录四条数据，那么就利用额外的扇区来记录更多的分区信息。实际如下图所示。
{% asset_img "2.png" "磁盘分区示意图" %}
从上图中可以看到，硬盘的四个分区仅使用到两个，P1为主分区，P2为扩展分区。扩展分区的目的是使用额外的扇区来记录分区，扩展分区**本身并不能被拿来格式化**。然后我们可以通过扩展分区所指向的那个块继续做分区的记录。
上图中由五个扩展分区继续切出来的分区，就被称为逻辑分区(logical partition)。同时，由于逻辑分区是由扩展分区继续分出来的，所以它可以使用的范围就是扩展分区所设定的范围。
所以总结起来就是：
- 主分区与扩展分区最多可以有四个(硬盘限制)。
- 扩展分区最多只能有一个(操作系统限制)。
- 逻辑分区是由扩展分区继续切割出来的分区。
- 能够被格式化后作为数据访问的分区为主分区与逻辑分区。扩展分区无法格式化。
- 逻辑分区的数量依操作系统而不同，在Linux系统中，IDE硬盘最多有59个逻辑分区(5号到63号)，SATA硬盘则有11个逻辑分区(5号到15号)。

--------------------------------------------

磁盘与文件系统
--------------
**1. 磁盘分区**
磁盘分区主要用到了fdisk命令。fdisk命令有几点要注意的地方：首先，这个命令几乎不用去记选项，使用m就能看到该命令的所有选项了。
{% codeblock %}
sudo fdisk /dev/sda

命令(输入 m 获取帮助)： m
命令操作
   a   toggle a bootable flag
   b   edit bsd disklabel
   c   toggle the dos compatibility flag
   d   delete a partition
   l   list known partition types
   m   print this menu
   n   add a new partition
   o   create a new empty DOS partition table
   p   print the partition table
   q   quit without saving changes
   s   create a new empty Sun disklabel
   t   change a partition's system id
   u   change display/entry units
   v   verify the partition table
   w   write table to disk and exit
   x   extra functionality (experts only)
{% endcodeblock %}

另一点就是，对去fdisk的所有操作，输入q之后不会保存，直接退出，**输入w**之后才会保存。
明白这两点之后，结合上面提到的磁盘分区表内容，就可以很容易学会磁盘分区了。

**2. 磁盘格式化**
在对磁盘完成分区之后，就可以对每个分区进行格式化了。格式化的命令非常简单，使用mkfs(即make file system之意)。这个命令其实是个综合的命令，它回去调用正确的文件系统格式化工具软件。
{% codeblock lang:bash %}
mkfs [-t文件系统格式] 设备名称
参数：
-t : 可以接文件系统格式，例如ext3, ext2, vfat等(系统有支持才会生效)
{% endcodeblock %}
mkfs其实是个综合命令，事实上，假如当我们使用“mkfs -t ext3...”时，系统会去调用mkfs.ext3这个命令来进行格式化的操作。
{% codeblock lang:bash %}
~$ mkfs [tab][tab]
mkfs          mkfs.ext2     mkfs.ext4dev  mkfs.msdos    
mkfs.bfs      mkfs.ext3     mkfs.fat      mkfs.ntfs     
mkfs.cramfs   mkfs.ext4     mkfs.minix    mkfs.vfat 
{% endcodeblock %}

**3. 磁盘挂载与卸载**
挂载点的意义：每个文件系统都有独立的inode,block,super block等信息，这个文件系统要能够连接到目录数才能被我们使用。将文件系统与目录数结合的操作我们称为**挂载**。需要注意的是：挂载点一定是目录，该目录为进入该文件的入口。同时，挂载点最好是一个空目录，因为挂载点被挂载之后，该目录下的原先文件会被隐藏，显示的是挂载磁盘分区的文件。
总结一下：
- 单一文件系统不应该被重复挂载在不同的挂载点(目录)中；
- 单一目录不应该重复挂载多个文件系统；
- 作为挂载点的目录理论上应该都是空目录才是。

文件系统挂载使用mount这个命令。最简单的挂载方法：
{% codeblock %}
mkdir /mnt/hdc6
mount /dev/hdc6 /mnt/hdc6
{% endcodeblock %}
由于文件系统几乎都有super block，linux可以通过分区super block搭配linux自己的驱动程序去测试挂载，如果成功挂载了，就立刻自动使用该类型的文件系统挂载起来，因此无需额外指定文件系统类型。详细的mount命令可以**man mount**。

**挂载CD或DVD光盘**
{% codeblock %}
$ mkdir /media/cdrom
$ mount -t iso9960 /dev/cdrom /media/cdrom
$ mount /dev/cdrom /media/cdrom
# 你可以指定-t iso9960 这个光盘的格式来挂载，也可以让系统自己去测试挂载
# 所以上述命令二选一就可以了
{% endcodeblock %}

**挂载U盘**
{% codeblock %}
$ mkdir /mnt/flash
$ mount -t vfat -o iocharset=cp950 /dev/sda1 /mnt/flash
{% endcodeblock %}
如果带有中文文件名的数据，那么可以在挂载时指定一下挂载文件系统所示用的语言。在man mount 找到vfat文件格式当中可以使用iocharset来指定语系，而中文语系是cp950，所以就有了上述的挂载命令选项了。

--------------------------------------------

文件系统的简单操作(df, du)
-------------------------
下面简单介绍一下df和du两个常用的命令
df:列出文件系统的整体磁盘使用量；
du:评估文件系统的磁盘使用量(常用语评估目录所占容量)。
{% codeblock %}
用法：df [选项]... [文件]...
  -a, --all             include dummy file systems
  -B, --block-size=SIZE  scale sizes by SIZE before printing them.  E.g.,
                           '-BM' prints sizes in units of 1,048,576 bytes.
                           See SIZE format below.
      --total           produce a grand total
  -h, --human-readable  print sizes in human readable format (e.g., 1K 234M 2G)
  -H, --si              likewise, but use powers of 1000 not 1024
  -i, --inodes		显示inode 信息而非块使用量
  -k			即--block-size=1K
  -l, --local		只显示本机的文件系统
      --no-sync		取得使用量数据前不进行同步动作(默认)
      --output[=FIELD_LIST]  use the output format defined by FIELD_LIST,
                               or print all fields if FIELD_LIST is omitted.
  -P, --portability     use the POSIX output format
      --sync            invoke sync before getting usage info
  -t, --type=TYPE       limit listing to file systems of type TYPE
  -T, --print-type      print file system type
  -x, --exclude-type=TYPE   limit listing to file systems not of type TYPE
  -v                    (ignored)
      --help		显示此帮助信息并退出
      --version		显示版本信息并退出

#例如
$ df -h
文件系统        容量  已用  可用 已用% 挂载点
/dev/sda2       9.1G  4.1G  4.5G   48% /
none            4.0K     0  4.0K    0% /sys/fs/cgroup
udev            999M  4.0K  999M    1% /dev
tmpfs           202M  1.1M  201M    1% /run
none            5.0M     0  5.0M    0% /run/lock
none           1008M   76K 1008M    1% /run/shm
none            100M   52K  100M    1% /run/user
/dev/sda1        88M   34M   48M   42% /boot
/dev/sda4       9.4G  3.3G  5.7G   37% /home
.host:/          51G   26G   25G   51% /mnt/hgfs
{% endcodeblock %}

df主要读取的数据几乎都是针对整个文件系统，因此读取的范围主要是在Super block内的信息，所以这个命令显示结果的速度非常快速。与df不一样，du这个命令其实会直接到文件系统内去查找所有的文件数据，所以命令执行会相对比较慢。详细也man一下吧，这里不再赘述。
