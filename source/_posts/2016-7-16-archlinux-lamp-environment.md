---
title: Arch Linux下LAMP环境搭建
tags:
  - linux
  - lamp
categories: Linux
author: yosef gao
date: 2016-07-16 11:00:20
---


LAMP
--------
所谓LAMP，即Linux+Apache+MySQL+PHP系统，本文以鸟哥服务器书为基础，结合笔者现有的ArchLinux环境，搭建一个LAMP系统。

<!--more-->

软件安装
---------
需要安装的软件有[Apache](https://wiki.archlinux.org/index.php/Apache_HTTP_Server)，[MySQL](https://wiki.archlinux.org/index.php/MySQL)(在archlinux下mysql的官方实现叫MariaDB)，[php](https://wiki.archlinux.org/index.php/PHP)，[php-apache](https://wiki.archlinux.org/index.php/Apache_HTTP_Server#Extensions)。首先先看一下ArchLinux下这些软件装了没，没有就装上吧。
{% codeblock lang:bash %}
[root@vuser mysql]# pacman -Sy php php-apache mariadb apache
[root@vuser mysql]# pacman -Q | grep -E 'php|apache|mariadb'
apache 2.4.23-1
libmariadbclient 10.1.14-1
mariadb 10.1.14-1
mariadb-clients 10.1.14-1
php 7.0.8-1
php-apache 7.0.8-1
{% endcodeblock %}

httpd配置
---------
apache的配置文件主要在`/etc/httpd/conf/httpd.conf`这个文件里，如果只是搭建这个环境，默认的配置文件已经可以了。来注意几个[配置选项](https://wiki.archlinux.org/index.php/Apache_HTTP_Server#Configuration)。
```
User http
```
apache是以root用户启动的，为了安全性考虑，启动之后apache会自动切换到该选项配置的用户，其中http这个用户是在apache安装过程中自动创建的。
```
Listen 80
```
Apach 监听的端口，要被外网访问，请在路由器开放此端口。如果是本地调试用，把这一行改为 Listen 127.0.0.1:80.
```
ServerAdmin you@example.com
```
管理员的电子邮件，在错误页面会展示给用户。
```
DocumentRoot "/srv/http"
```
网页的目录.如果需要可以修改这个目录，请记得同步修改 <Directory "/srv/http"> 和DocumentRoot,否则访问新位置时可能出现 403 Error (缺少权限)问题。不要忘记修改 Require all denied 行到 Require all granted，否则会出现 403 Error. DocumentRoot 目录及其父目录必须有可执行权限，这样再能被服务器进程使用的用户访问到(用 chmod o+x /path/to/DocumentRoot 设置)，否则会出现 403 Error.
```
AllowOverride None
```
在 <Directory> 段落中的这个设置会让 Apache 完全忽略 .htaccess 文件。从 Apache 2.4，这个设置以及是默认的，所以如果要使用 .htaccess，请允许Overide. 如果要在 .htaccess 中使用 mod_rewrite 或其它设置, 可以指定哪些目录允许覆盖服务器配置。

修改完配置之后可以使用`apachectl configtest`命令检查配置文件是否存在问题。
{% codeblock lang:bash %}
[root@vuser mysql]# apachectl configtest
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using fe80::87f8:2d1a:70cb:1d60. Set the 'ServerName' directive globally to suppress this message
Syntax OK
{% endcodeblock %}
这里笔者没有设置域名，所以会出现这个问题，没有关系。

php配置
-------
php-apache 中包含的 libphp7.so 不支持 mod_mpm_event，仅支持 mod_mpm_prefork(FS#39218)。需要在 /etc/httpd/conf/httpd.conf 中注释掉:
```
#LoadModule mpm_event_module modules/mod_mpm_event.so
```
取消下面行的注释:
```
LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
```
不然将发生下面的错误:
```
Apache is running a threaded MPM, but your PHP Module is not compiled to be threadsafe.  You need to recompile PHP.
AH00013: Pre-configuration failed
httpd.service: control process exited, code=exited status=1
```

在`/srv/http`目录中创建test.php文件(如果没有修改DocumentRoot的话)，在其中写入`<?php phpinfo(); ?>`
{% codeblock lang:bash %}
echo '<?php phpinfo(); ?>' > /srv/http/test.php
{% endcodeblock %}

mysql配置
------------
安装Maria软件包之后，你必须运行下面这条命令：
{% codeblock lang:bash %}
# mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
{% endcodeblock %}
启动 mysqld 守护进程，运行安装脚本，然后重新启动守护进程：
{% codeblock lang:bash %}
# systemctl start mysqld
# mysql_secure_installation
# systemctl restart mysqld
{% endcodeblock %}
进行安全设置的时候会有一些步骤，根据实际情况设置就行了。

启动lamp系统
-----------
其实就是启动apache，`systemctl start httpd`就可以了，访问一下`http:\\localhost\test.php`，应该能看到输出的phpinfo信息了。
