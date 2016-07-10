---
title: su与sudo
tags: linux
categories: Linux
author: yosef gao
date: 2016-07-08 14:13:41
---


在linux中，用切换不同身份去执行不同的任务是很常见的事情，本文在鸟哥linux私房菜书的基础上，归纳总结了用户身份切换命令su与sudo命令的常见用法与说明。

<!--more-->

su
----
su是最简单的身份切换命令，它可以进行任何身份的切换，方法如下：
{% codeblock lang:bash %}
su [-lm] [-c 命令] [username]
#参数：
#- : 单纯使用-如“su -”代表使用login-shell等变量文件读取方式来登陆系统，如用户名称没有加上去，则代表切换为root身份
#-l : 与-类似，但后面需要加欲切换的用户帐号，也是login-shell的凡是
#-m : -m与-p是一样的，表示使用目前的环境设置，而不读取新用户的配置文件 
#-c : 近进行一次命令，所以-c后面可以加上命令
{% endcodeblock %}
因此，从解一下就是：
- 若要完整切换到新用户的环境，必须要使用“su -username”或“su -l username”，才会连同PATH/USER/MAIL等变量都转成心用户的环境；
- 如果仅想执行一次root命令，可以利用“su - -c 命令”的方式来处理；
- 使用root切换成为任何用户时，并不去药输入心用户的密码。

虽然使用su很方便，不过缺点是，当主机是多人管理的环境时，如果大家都使用su来切换成为root的身份，那么每个人都需要知道root密码，这样密码太多人知道可能会流出去，这时就可以用sudo来处理。

sudo
-----
相对于su需要了解新切换的用户密码，sudo的执行则仅需要自己的密码即可。甚至也可以设置不需要密码即可执行。
sudo的执行流程一般是这样的：
1. 当用户执行sudo时，系统于/etc/sudoers文件中查找该用户是否有执行sudo的权限；
2. 若用户具有可执行sudo的权限后，让用户输入自己的密码来确认；
3. 若密码输入成功，便开始进行sudo后续的命令(但root执行sudo时不需要输入密码)；
4. 若欲切换的身份与执行者身份相同，那也不需要输入密码。

因此sudo执行的重点是，能否使用sudo必须要看/etc/sudoers的设置值，而可使用sudo的是通过输入用户自己的密码来执行后续的命令串。因此，我们需要去编辑/etc/sudoers文件，不过该文件不能直接编辑，因为/etc/sudoers是有语法的，如果设置错误会造成无法使用sudo命令的不良后果，因此需要使用visudo去修改，并在结束离开修改界面时，系统回去检验/etc/sudoers的语法。visudo默认调用的是vi编辑器，如果需要使用其他编辑器，比如vim的话，在该命令前加上EDITOR环境变量即可，即`# EDITOR=vim visudo`。

**1.单用户设置**
/etc/sudoers文件的语法如下：
{% codeblock lang:bash %}
用户帐号	登陆者的来源主机名=(可切换的身份)	可执行的命令
root		ALL=(ALL)				ALL
{% endcodeblock %}
这4个参数的意义为：
1. 用户帐号：系统的哪个帐号可以使用sudo这个命令，默认为root这个帐号。
2. 登陆者的来源主机名：这个帐号由哪台主机连接到本Linux主机，意思是这个帐号可能是由哪一台网络主机连接过来的，这个设置值可以指定客户端计算机(信任用户)。默认值root可来自任何一台网络主机。
3. 可切换的身份：这个帐号可以切换成什么身份来执行后续的命令，默认root可以切换成任何人。
4. 可执行的命令：这个命令务必使用囧对路径编写。默认root可以切换任何身份并且进行任何命令。
ALL是特殊的关键字，代表任何身份、主机或命令的意思。

**2.用户组设置**
当在用户帐号一栏的名字前加上%则表示这是一个用户组的意思。比如
{% codeblock lang:bash %}
用户帐号	登陆者的来源主机名=(可切换的身份)	可执行的命令
%wheel		ALL=(ALL)				ALL
{% endcodeblock %}
上面设置值会造成任何加入wheel这个用户组的用户就能够使用sudo切换任何身份来操作任何命令。

**3.操作限制**
如果想让用户仅能进行部分系统任务，在可执行命令处填上命令的绝对路径(注意必须是绝对路径)。如
{% codeblock lang:bash %}
用户帐号	登陆者的来源主机名=(可切换的身份)	可执行的命令
user1		ALL=(root)				/usr/bin/passwd
{% endcodeblock %}
上面的设置值指的是user1可以切换成为root使用passwd这个命令。不过这个设置有一点问题
{% codeblock lang:bash %}
#当前身份user1
$ sudo passwd user2 	# 修改user2的密码，这样是可以的
$ sudo passwd		# 这样会修改root的密码，这是不允许的
{% endcodeblock %}
因此修改为如下
{% codeblock lang:bash %}
用户帐号	登陆者的来源主机名=(可切换的身份)	可执行的命令
user1		ALL=(root)				!/usr/bin/passwd, /usr/bin/passwd [A-Za-z]*, !/usr/bin/passwd root
{% endcodeblock %}
"!"表示不可执行的意思，因此上面这一行变成可以执行“passwd任意字符”，但是不允许执行“passwd”和“passwd root”，这样root的密码就不会被修改了。

**4.visudo别名设置**
当需要批量添加用户进入管理员行列时，每一个用户添加一行显然是比较麻烦的事情，可以通过下述方法简单实现。
{% codeblock lang:bash %}
User_Alias ADMPW = user1, user2, user3
Cmnd_Alias ADMPWCOM = !/usr/binpasswd, /usr/bin/passwd [A-Za-z]*, !/usr/bin/passwd root
{% endcodeblock %}
通过User\_Alias(帐号别名)新建一个帐号，这个帐号名称一定要使用大写字符来处理，包括Cmnd\_Alias(命令别名)、Host\_Alias(来源主机别名)都需要使用大写字符。

**5.sudo与su**
很多时候需要大量执行很多root工作，所以一直使用sudo很麻烦。一下方法可以使用sudo搭配su，转为root身份，而且不需要暴露root密码。
{% codeblock lang:bash %}
# visudo
User_Alias ADMINS = user1, user2
ADMINS ALL=(root) /bin/su -
{% endcodeblock %}
接下来，上述的user1,user2这两个人，只要输入“sudo su -”并且输入自己的密码后，就立刻变成root身份，完成人物之后再使用“exit”退出就可以了。
