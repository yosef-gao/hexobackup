---
title: 突破网易云音乐播放列表1000限制
tags:
  - 'c#'
  - python
categories: Program
author: yosef gao
date: 2016-07-29 14:21:47
---


笔者是网易云音乐的忠实粉丝，从14年使用至今。最喜欢的还是云音乐的评论功能，总能找到一些有趣的评论，总能找到一些喜欢同一首歌的知音。不过云音乐有一个不知道是不是有意为之的缺点，当前播放列表的大小被限制在了1000以内。像笔者这种听到喜欢的歌就点红心的人，收藏的歌单列表早就超过了1000首，这意为着每次都只能听到最近收藏的1000首歌，之前的歌如果想要听到的话，还要自己手动往前翻歌单，小心翼翼添加到播放列表，防止超出1000首，很麻烦！
<!--more-->
笔者也曾多次像小秘书反映这个问题，很奇怪别人联系小秘书都能得到答复，为什么笔者就没有这个待遇？
{% asset_img "1.jpg" "开发组"%}
{% asset_img "2.jpg" "小秘书"%}
既然反映问题没有答复，那就自己动手丰衣足食吧。

基本思路
---------
大致构思了一下，实现分为两部分：1. 用云音乐的API爬取指定的播放列表的详细歌单，保存到本地备用；2. 本地读取歌单，随机挑选歌曲，模拟鼠标键盘事件去操作云音乐的客户端，通过客户端的搜索功能找到该歌曲并播放。由于本地自己保存的歌单是没有1000首歌的限制的，所以间接达到了目的。是的，就是这种很土很直接的方法，破解网易云音乐客户端什么的太难了……

爬取歌单
-----------
这部分其实Github上开源的关于网易云音乐API分析的文章和代码很多，笔者看到的是[网易云音乐API分析（v2）新](https://github.com/metowolf/NeteaseCloudMusicApi/wiki/%E7%BD%91%E6%98%93%E4%BA%91%E9%9F%B3%E4%B9%90API%E5%88%86%E6%9E%90%EF%BC%88v2%EF%BC%89%E6%96%B0) 以及 [网易云音乐新版WebAPI分析](https://github.com/darknessomi/musicbox/wiki/%E7%BD%91%E6%98%93%E4%BA%91%E9%9F%B3%E4%B9%90%E6%96%B0%E7%89%88WebAPI%E5%88%86%E6%9E%90%E3%80%82)这两篇。大致介绍一下，获取歌单POST到这个url就可以了`POST http://music.163.com/weapi/v3/playlist/detail?csrf_token=`，参数如下
```
req = {
	"id": playlist_id,
        "offset": 0,
	"total": True,
	"limit": 1000,
	"n": 1000,
	"csrf_token": csrf
}
```
这里关键是post的参数是需要经过两部加密的，具体的加密方式就详见上面两篇文章吧，这里就不再详细介绍了。
抓取到的是json的数据，格式在[网易云音乐API分析（v2）新](https://github.com/metowolf/NeteaseCloudMusicApi/wiki/%E7%BD%91%E6%98%93%E4%BA%91%E9%9F%B3%E4%B9%90API%E5%88%86%E6%9E%90%EF%BC%88v2%EF%BC%89%E6%96%B0)一文中也有介绍，这里需要提取出的是json["playlist"]["trackIds"]数组里的数据，每一项的形式如下：
```
{
	["id"] => int(35847388)
	["v"] => int(11)
}
```
其中id是我们需要的，保存下来就行了。

本地客户端
----------
本地客户端需要做的就是向云音乐客户端发送模拟的鼠标和键盘消息就可以。首先来看一下，假设我们有一首歌的id，那么手动切到这首歌是怎么做的，如下图
{% asset_img "steps.png" "步骤"%}
假设歌曲id已经在系统的剪切板里了，首先点击搜索框，双击全选，然后ctrl+v粘贴，回车搜索歌曲，接着点击单曲(我们只需要显示搜索到的歌曲就行了)，然后点击第一首歌，OK，开始播放了。这里要感谢网易云音乐的客户端搜索歌曲ID也是能搜到歌的，而且搜到的结果是唯一的，就是这首歌。

模拟鼠标和键盘事件用到Windows API的调用，这里用c#来写，需要import这几个函数
{% codeblock lang:csharp %}
// 发送键盘消息
[DllImport("user32.dll")]
public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, uint dwExtraInfo);
// post 消息
[DllImport("User32.dll", EntryPoint = "PostMessage")]
public static extern int PostMessage(IntPtr hWnd, uint Msg, uint wParam, uint lParam); 
// 查找窗口句柄
[DllImport("user32.dll", EntryPoint = "FindWindow")]
public static extern IntPtr FindWindow(string lpClassName, string lpWindowName); 
// 查找子窗口句柄
[DllImport("user32.dll", EntryPoint = "FindWindowEx")]
public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow); 
{% endcodeblock %}

接下来介绍一个vs下很好用的工具spy++，知道可以跳过这一段了。使用 Spy++ 可以执行下列操作： 显示系统对象（包括进程、线程和窗口）之间关系的图形树。 搜索指定的窗口、线程、进程或消息。 查看选定的窗口、线程、进程或消息的属性。spy++在vs的工具菜单下。
这里通过spy++来查看云音乐客户端的窗口类(或者查看窗口标题)，用于获取窗口句柄来向它发送消息。
{% asset_img "spy++.jpg" "spy++"%}
首先ctrl+f调出上图的窗口，选择属性，把雷达符号拖到云音乐的窗口上后松开鼠标，点击确定后就可以看到该窗口做的一些属性了，点同步还可以看到窗口之间的树形图。
{% asset_img "tree.jpg" "云音乐窗口树形图"%}
从图中看到，我们要获取的是类名为“Chrome_WidgetWin_0”的子窗口的句柄，所以我们要依次查找类名为“OrpheusBrowserHost”的父窗口，然后以该父窗口的句柄为参数查找类名为“CefBrowserWindow”的子窗口句柄，再以该子窗口句柄为参数查找类名为“Chrome_WidgetWin_0”的子窗口句柄，即为我们需要的窗口句柄。
{% codeblock lang:csharp %}
/*
 * SystemCallUtils是封装上述系统调用的类
 */
IntPtr handle = SystemCallUtils.FindWindow("OrpheusBrowserHost", null);
if (handle != IntPtr.Zero)
{
	handle = SystemCallUtils.FindWindowEx(handle, IntPtr.Zero, "CefBrowserWindow", null);
	handle = SystemCallUtils.FindWindowEx(handle, IntPtr.Zero, "Chrome_WidgetWin_0", null);
}
{% endcodeblock %}
有了窗口句柄之后我们就可以向它发送消息了。这里还需要用spy++先捕获一下消息，主要是为了获得鼠标点击不同位置时的参数。具体做法和上面一样，但是spy++的属性单选改为消息。然后在云音乐客户端上操作一遍上文提到的切歌的操作，可以看到spy++把消息都截获下来了，样子如下图
{% asset_img "messages.jpg" "消息"%}
这里需要做的就是从这一大堆消息中找到那几个关键的消息，即鼠标双击搜索框，ctrl+v粘贴……，查看这些消息的lParam和wParam，记录下来，并在代码中模拟这些消息的发送。是的，这就是一个体力活，而且对于不同分辨率，或者不同云音乐客户端大小的用户来说，这些参数都是不一样的，不过目前还没有找到更好的方法，欢迎补充。笔者找到这些参数之后，写了一段代码来模拟消息的发送，可以成功切歌。
{% codeblock lang:csharp %}
/*
 * 常量定义
 */
public const int WM_CHAR = 0x0102;
public const int WM_MOUSEMOVE = 0x0200;
public const int WM_LBUTTONDOWN = 0x0201;
public const int WM_LBUTTONUP = 0x0202;
public const int WM_LBUTTONDBLCLK = 0x203;
public const int WM_KEYDOWN = 0x0100;
public const int WM_KEYUP = 0x0101;
public const int VK_CONTROL = 0x11;
public const int VK_V = 0x56;
public const int VK_RETURN = 0x0D;

// 鼠标移动到搜索框
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_MOUSEMOVE, 0x00, 0x001B014E);
Thread.Sleep(10);

// 让网易云客户端获得焦点
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_LBUTTONDOWN, 0x01, 0x001B014E);
Thread.Sleep(10);
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_LBUTTONUP, 0x00, 0x001B014E);
Thread.Sleep(10);

// 鼠标双击搜索框
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_LBUTTONDOWN, 0x01, 0x001B014E);
Thread.Sleep(10);
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_LBUTTONDBLCLK, 0x01, 0x001B014E);
Thread.Sleep(10);
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_LBUTTONUP, 0x00, 0x001B014E);
Thread.Sleep(10);

// 发送ctrl+v，粘贴
SystemCallUtils.keybd_event(SystemCallUtils.VK_CONTROL, 0, 0, 0); // 用keybord event 发送ctrl
Thread.Sleep(10);
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_KEYDOWN, SystemCallUtils.VK_V, 0x002F0001);
Thread.Sleep(10);
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_CHAR, 0x016, 0x002F0001);
Thread.Sleep(10);
SystemCallUtils.keybd_event(SystemCallUtils.VK_CONTROL, 0, 0x02, 0);
Thread.Sleep(10);
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_KEYUP, SystemCallUtils.VK_V, 0xC02F0001);
Thread.Sleep(10);

// 回车
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_KEYDOWN, SystemCallUtils.VK_RETURN, 0x001C001);
Thread.Sleep(10);
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_KEYUP, SystemCallUtils.VK_RETURN, 0xC01C001);

// 点击单曲
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_MOUSEMOVE, 0x00, 0x00870119);
Thread.Sleep(10);
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_LBUTTONDOWN, 0x01, 0x00870119);
Thread.Sleep(10);
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_LBUTTONUP, 0x00, 0x00870119);
Thread.Sleep(10);

// 等待云音乐客户端刷新
Thread.Sleep(1000);

// 移动到第一个
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_MOUSEMOVE, 0x00, 0x00C30151);
Thread.Sleep(10);
// 按下鼠标左键
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_LBUTTONDOWN, 0x01, 0x00C30151);
Thread.Sleep(10);
// 双击
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_LBUTTONDBLCLK, 0x01, 0x00C30151);
Thread.Sleep(10);
// 松开
SystemCallUtils.PostMessage(test, SystemCallUtils.WM_LBUTTONUP, 0x00, 0x00C30151);
Thread.Sleep(10);
{% endcodeblock %}

总结
------
这样，主要的逻辑其实已经完成了，剩下的就是把两部分内容结合起来，一些边边角角的代码了。其实这个方法鲁帮性很差，比如说那个等待网页刷新笔者给了1000ms的等待时间，但是如果上一首歌还没加载完的话，这1000ms时间是不够刷新的，这个时候切歌就失败了。另外，如果要做到连续播放，最好能在上一首歌播放完的时候实现自动切歌，这样就需要在爬取歌单的时候，顺便把时间也爬取下来。类似的问题还有很多很多，此文就当是抛砖引玉，希望能看到更好更路棒的方法。
最后的最后，鄙视一下网易云音乐的开发组，这个功能很难实现吗？不能实现给个回复不行吗？
[github代码](https://github.com/yosef-gao/CloudMusicPlugin)
