---
title: Markdown 语法的简要规则
date: 2016-03-13 13:07:57
author: yosef gao
tags: markdown
categories: Others
---

这里摘录一些Markdown的简要语法规则，方便查寻，主要参考[Markdown 语法说明 (简体中文版)](http://www.appinn.com/markdown)。

<!--more-->

标题
----
Markdown 支持两种标题的语法，类 [Setext](http://docutils.sourceforge.net/mirror/setext.html) 和类 [atx](http://www.aaronsw.com/2002/atx/) 形式。
类 Setext 形式是用底线的形式，利用 `=` （最高阶标题）和 `-`（第二阶标题），例如：
```
This is an H1
=============
This is an H2
-------------
```
显示效果：
This is an H1
=========
This is an H2
------------
任何数量的 `=`和 `-`都可以有效果。
类 Atx 形式则是在行首插入 1 到 6 个`#`，对应到标题 1 到 6 阶，例如：
```
# 这是 H1

## 这是 H2

###### 这是 H6
```
--------------------

区块引用 Blockquotes
---------------------
Markdown 标记区块引用是使用类似 email 中用`>`的引用方式。
```
> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
> consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
> Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
> 
> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
> id sem consectetuer libero luctus adipiscing.
```
Markdown 也允许你偷懒只在整个段落的第一行最前面加上 >
```
> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. 
Suspendisseid sem consectetuer libero luctus adipiscing.
```
------------------
列表
----
Markdown 支持有序列表和无序列表。
无序列表使用星号、加号或是减号作为列表标记：
```
* Red
* Green
* Blue
```
等同于：
```
+ Red
+ Green
+ Blue
```
也等同于：
```
- Red
- Green
- Blue
```
有序列表则使用数字接着一个英文句点：
```
1. First
2. Second
3. Third
```
很重要的一点是，你在列表标记上使用的数字并不会影响输出的 HTML 结果，上面的列表所产生的 HTML 标记为：
```
<ol>
<li>First</li>
<li>Second</li>
<li>Third</li>
</ol>
```
你可以让 Markdown 文件的列表数字和输出的结果相同，或是你懒一点，你可以完全不用在意数字的正确性。

如果你使用懒惰的写法，建议第一个项目最好还是从 1. 开始，因为 Markdown 未来可能会支持有序列表的 start 属性。

列表项目标记通常是放在最左边，但是其实也可以缩进，最多 3 个空格，项目标记后面则一定要接着至少一个空格或制表符。

如果列表项目间用空行分开，在输出 HTML 时 Markdown 就会将项目内容用 `<p>`标签包起来，举例来说：
```
* Bird
* Magic
```
会被转换为：
```
<ul>
<li>Bird</li>
<li>Magic</li>
</ul>
```
但是这个：
```
* Bird

* Magic
```
会被转换为：
```
<ul>
<li><p>Bird</p></li>
<li><p>Magic</p></li>
</ul>
```
如果要在列表项目内放进引用，那`>`就需要缩进：
```
* A list item with a blockquote: 
  > This is a blockquote 
  > inside a list item.
```

---------------

强调
---------
Markdown 使用星号`（*）`和底线`（_）`作为标记强调字词的符号，被`*`或`_`包围的字词会被转成用`<em>`标签包围，用两个`*`或`_`包起来的话，则会被转成`<strong>`
```
*斜体*
_斜体_
**粗体**
__粗体__
```
*斜体* 
_斜体_ 
**粗体** 
__粗体__ 

---------------------------------

代码
---
如果要标记一小段行内代码，你可以用反引号把它包起来``（`）``，例如：
```
Use the `printf()` function.
```
如果要在代码区段内插入反引号，你可以用多个反引号来开启和结束代码区段：
```
``There is a literal backtick (`) here.``
```

--------------

自动链接
---------
Markdown 支持以比较简短的自动链接形式来处理网址和电子邮件信箱，只要是用方括号包起来， Markdown 就会自动把它转成链接。一般网址的链接文字就和链接地址一样，例如：
```
<http://example.com/>
```
邮址的自动链接也很类似，只是 Markdown 会先做一个编码转换的过程，把文字字符转成 16 进位码的 HTML 实体，这样的格式可以糊弄一些不好的邮址收集机器人，例如：
```
<address@example.com>
```

 ----------

图片
------
图片的插入不同平台提供了特殊的方法。常用的方式是：
```
![Alt text](/path/to/img.jpg)
![Alt text](/path/to/img.jpg "Optional title")
```
-------------

表格
------
表格的插入比较累人，示意如下
```
| Tables        | Are        |  Cool         |
| :------------ |:----------:| -------------:|
| left-aligned  | centered   | right-aligned |
| col 1         | col 2      | col3          |
| 123           | 456        | 789           |
```
效果如下：

| Tables        | Are        |  Cool         |
| :------------ |:----------:| -------------:|
| left-aligned  | centered   | right-aligned |
| col 1         | col 2      | col3          |
| 123           | 456        | 789           |

公式
----------
公式插入的方式有三种：
**方法一： 使用Google Chart的服务器**
```
<img src="http://www.forkosh.com/mathtex.cgi? 在此处插入Latex公式">
```
给个例子
```
<img src="http://chart.googleapis.com/chart?cht=tx&chl=\Large x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}" style="border:none;">
```
显示效果为：
<img src="http://chart.googleapis.com/chart?cht=tx&chl=\Large x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}" style="border:none;">

**方法二：使用forkosh服务器**
```
<img src="http://www.forkosh.com/mathtex.cgi? 在此处插入Latex公式">
```
同样给个例子
```
<img src="http://www.forkosh.com/mathtex.cgi? \Large x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}">
```
显示效果为：
<img src="http://www.forkosh.com/mathtex.cgi? \Large x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}">

**方法三：使用MathJax引擎**
前两种方法生成的都是图片，当公式一多的时候网页加载会比较慢，第三种方法调用MathJax引擎来渲染公式，所以生成的不是图片，使用方法为在Markdown中添加MathJax引擎
```
<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
```
然后，再使用Tex写公式。`$$公式$$`表示行间公式，本来Tex中使用`\(公式\)`表示行内公式，但因为Markdown中`\`是转义字符，所以在Markdown中输入行内公式使用`\\(公式\\)`，代码如下：
```
$$x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}$$
\\(x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}\\)
```
显示效果为：
<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
行间公式：$$x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}$$
行内公式：\\(x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}\\)

最后再附上[forkosh](http://www.forkosh.com/mathtextutorial.html)网站，上面有对Tex语法的详细描述。
