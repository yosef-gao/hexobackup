---
title: 在VS2015下配置OpenCV3.10环境
tags:
  - opencv
author: yosef gao
categories: Tools
date: 2016-04-23 14:23:35
---


前言
------
OpenCV更新3.x系列的第一个稳定版本3.10了。为了跟上时代的潮流，重新装一个最新的OpenCV版本，顺便记录一下配置过程。

<!--more-->

安装OpenCV3.10
--------------
这一步其实没什么好说的，从OpenCV[官网](http://opencv.org/documentation.html)下载最新的OpenCV for windows版本，然后解压就行了，这里假设解压的根目录为X:\\OpenCV。

配置环境变量
----------------
添加环境变量就用以下3张图来说明应该就足够了。注意，这里在环境变量`Path`中添加的就是上文中提到的`X:\\OpenCV\\opencv\\build\\x64\\vc14\\bin`。其中x64和x86取决于你的系统环境，vc14对应vs2015，vc13对应vs2013，vc12对应vs2011，vc11对应vs2010，本文使用vs2015。

{% asset_img "step1.png" "第1步，选择环境变量" %}
{% asset_img "step2.png" "第2步，编辑系统变量Path" %}
{% asset_img "step3.png" "第3步，添加OpenCV bin目录" %}

配置属性表
-----------
有人喜欢先建一个vc++的模板工程，然后配置好opencv环境，下次直接使用这个模板就行了，不过我更喜欢配置属性表。
首先新建一个vc++的控制台空项目。
{% asset_img "step4.png" "新建vc++控制台空项目" %}
然后添加一个新的属性表，名字就叫OpenCV310好了，以后都用得着。
然后直接编辑这个属性表，内容如下，需要注意的是其中的OpenCV目录改为自己对应的目录即可：

{% codeblock lang:xaml %}
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ImportGroup Label="PropertySheets" />
  <PropertyGroup Label="UserMacros" />
  <PropertyGroup>
    <IncludePath>D:\opencv310\opencv\build\include;$(IncludePath)</IncludePath>
    <ExecutablePath Condition="'$(Platform)'=='Win32'">D:\opencv310\opencv\build\x86\vc14\bin;$(ExecutablePath)</ExecutablePath>
    <ExecutablePath Condition="'$(Platform)'=='X64'">D:\opencv310\opencv\build\x64\vc14\bin;$(ExecutablePath)</ExecutablePath>
    <LibraryPath Condition="'$(Platform)'=='Win32'">D:\opencv310\opencv\build\x86\vc14\lib;$(LibraryPath)</LibraryPath>
    <LibraryPath Condition="'$(Platform)'=='X64'">D:\opencv310\opencv\build\x64\vc14\lib;$(LibraryPath)</LibraryPath>
  </PropertyGroup>
  <ItemDefinitionGroup>
    <Link Condition="'$(Configuration)'=='Debug'">
      <AdditionalDependencies>opencv_world310d.lib;%(AdditionalDependencies)</AdditionalDependencies>
    </Link>
    <Link Condition="'$(Configuration)'=='Release'">
      <AdditionalDependencies>opencv_world310.lib;%(AdditionalDependencies)</AdditionalDependencies>
    </Link>
  </ItemDefinitionGroup>
  <ItemGroup />
</Project>
{% endcodeblock %}

OK，然后新建一个cpp文件测一下是否大功告成把。

{% codeblock lang:cpp %}
#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <iostream>

using namespace cv;
using namespace std;

int main(int argc, char** argv)
{
    Mat image;
    image = imread("You test picture path here!", IMREAD_COLOR); // Read the file
    if (image.empty()) // Check for invalid input
    {
        cout << "Could not open or find the image" << std::endl;
        return -1;
    }
    namedWindow("Display window", WINDOW_AUTOSIZE); // Create a window for display.
    imshow("Display window", image); // Show our image inside it.
    waitKey(0); // Wait for a keystroke in the window
    return 0;
}
{% endcodeblock %}

然后把opencv310.props备份一份放在自己喜欢的地方，下次新建工程的时候直接把该属性表添加进来就可以了。
Have fun with OpenCV!
