---
title: cJSON源码解析(1)
tags:
  - json
  - c/c++
categories: Program
author: yosef gao
date: 2016-07-25 19:39:32
---


cJSON是一个轻巧的，ANSI-C标准的json解析库，其代码只有1000+行，写得非常漂亮，适合用来学习。本文结合cjson的源码简单分析该json库。学习cJSON之前可以先看一下[json的简介](/2016/07/25/json/#more)。

<!--more-->

数据结构定义
---------
json里面的数据有7形式，在cJSON中定义如下：
{% codeblock lang:c %}
/* cJSON Types: */
#define cJSON_False  (1 << 0)
#define cJSON_True   (1 << 1)
#define cJSON_NULL   (1 << 2)
#define cJSON_Number (1 << 3)
#define cJSON_String (1 << 4)
#define cJSON_Array  (1 << 5)
#define cJSON_Object (1 << 6)

/* 这两种定义在下文中会有描述 */
#define cJSON_IsReference 256
#define cJSON_StringIsConst 512
{% endcodeblock %}

json数据的采用了树的形式存储，其中每一个节点cJSON的定义如下：
{% codeblock lang:c %}
/* cJSON结构: */
typedef struct cJSON {
	struct cJSON *next,*prev;	/* 双向链表的next和prev指针，指向该节点的兄弟节点 */
	struct cJSON *child;		/* 子节点指针 */

	int type;			/* 节点的数据类型，就是上面定义的7+2种 */

	char *valuestring;		/* 如果type==cJSON_String，那么这个指针指向了存放字符串的内存 */
	int valueint;			/* 如果type==cJSON_Number，那么存放了数字的值(int 型) */
	double valuedouble;		/* 如果type==cJSON_Number，那么存放了数字的值(double 型) */

	char *string;			/* 如果是对象的key-value元素的话，存放了key值 */
} cJSON;
{% endcodeblock %}

解析类函数
----------
cJSON定义了许多函数，我把这些函数做了简单的分类，大致可以分为4类：解析类函数，打印类函数，节点操作类函数(节点增删查改)，其他函数。首先先来看一下解析类函数。解析类函数中最重要的就是`cJSON_Parse`，该函数传入一个json字符串，并把他解析成cJSON格式的链表。
{% codeblock lang:c %}
/* Default options for cJSON_Parse */
cJSON *cJSON_Parse(const char *value) {return cJSON_ParseWithOpts(value,0,0);}
{% endcodeblock %}
该函数调用了`cJSON_ParseWithOpts`函数，在这个函数中，省略其他细枝末节，最关键的是调用了`parse_value`函数，其函数定义如下：
{% codeblock lang:c %}
/* Parser core - when encountering text, process appropriately. */
static const char *parse_value(cJSON *item,const char *value,const char **ep)
{
	if (!value)						return 0;	/* Fail on null. */
	if (!strncmp(value,"null",4))	{ item->type=cJSON_NULL;  return value+4; }
	if (!strncmp(value,"false",5))	{ item->type=cJSON_False; return value+5; }
	if (!strncmp(value,"true",4))	{ item->type=cJSON_True; item->valueint=1;	return value+4; }
	if (*value=='\"')				{ return parse_string(item,value,ep); }
	if (*value=='-' || (*value>='0' && *value<='9'))	{ return parse_number(item,value); }
	if (*value=='[')				{ return parse_array(item,value,ep); }
	if (*value=='{')				{ return parse_object(item,value,ep); }

	*ep=value;return 0;	/* failure. */
}
{% endcodeblock %}
该函数是解析json字符串的核心函数，通过比较字符串的首个字符来判数据类型，并调用相应数据类型的解析函数来解析，比如字符串以`"`开头，那么可以假设后面的数据类型是字符串类型，调用`parse_string`函数来解析。当然，这里只是假设后面是字符串类型，如果解析下去发现格式不符，那么就报错返回。由于json数据类型之间是可以相互嵌套的，比如对象类型里面可以嵌套数组类型，数组类型里面又可以嵌套对象类型，因此，解析的时候其实也是一个函数递归调用的过程。

下面来看`parse_string`解析函数：
{% codeblock lang:c %}
static const char *parse_string(cJSON *item,const char *str,const char **ep)
{
	/* 省略部分代码 */
	while (*end_ptr!='\"' && *end_ptr && ++len) if (*end_ptr++ == '\\') end_ptr++;	/* 计算字符串的长度 */
	out=(char*)cJSON_malloc(len+1);	
	if (!out) return 0;
	item->valuestring=out; /* assign here so out will be deleted during cJSON_Delete() later */
	item->type=cJSON_String;
	/* 省略部分代码 */
	while (ptr < end_ptr)
	{
		if (*ptr!='\\') *ptr2++=*ptr++;
		else
		{
			ptr++;
			switch (*ptr)
			{
				case 'b': *ptr2++='\b';	break;
				case 'f': *ptr2++='\f';	break;
				case 'n': *ptr2++='\n';	break;
				case 'r': *ptr2++='\r';	break;
				case 't': *ptr2++='\t';	break;
				case 'u':	 /* transcode utf16 to utf8. */
					uc=parse_hex4(ptr+1);ptr+=4;	/* get the unicode char. */
					/* 省略部分代码 */
				default:  *ptr2++=*ptr; break;
			}
			ptr++;
		}
	}
	/* 省略部分代码 */
	return ptr;
}
{% endcodeblock %}
可以看到，整个函数的框架就是按照下图的状态机来解析json字符串的。函数首先计算字符串的长度，即寻找字符串的结尾`"`，并且计算长度的时候跳过转义符`\`。计算完长度之后为字符串分配相应的内存空间，并把字符逐个拷贝到分配的内存空间中。拷贝的过程中需要处理几个特殊的转义字符以及unicode字符(以\u开头)，其中unicode通过`parse_hex4`函数特殊处理，这个函数就不详细展开了。
{% asset_img "string.gif" "string" %}

`parse_number`函数用于解析数字，其函数定义如下：
{% codeblock lang:c %}
/* Parse the input text to generate a number, and populate the result into item. */
static const char *parse_number(cJSON *item,const char *num)
{
	double n=0,sign=1,scale=0;int subscale=0,signsubscale=1;

	if (*num=='-') sign=-1,num++;			/* 符号 */
	if (*num=='0') num++;				/* is zero */
	if (*num>='1' && *num<='9') {
		do
			n=(n*10.0)+(*num++ -'0');
		while (*num>='0' && *num<='9');		/* 整数部分 */
	}
	if (*num=='.' && num[1]>='0' && num[1]<='9') {
		num++;		
		do	
			n=(n*10.0)+(*num++ -'0'),scale--; 
		while (*num>='0' && *num<='9');
	}						/* 小数部分 */
	if (*num=='e' || *num=='E') {			/* 指数部分 */
		num++;
		if (*num=='+') 
			num++;	
		else if (*num=='-') 
			signsubscale=-1,num++;		/* With sign? */
		while (*num>='0' && *num<='9') 
			subscale=(subscale*10)+(*num++ - '0');	/* Number? */
	}

	n=sign*n*pow(10.0,(scale+subscale*signsubscale));	/* number = +/- number.fraction * 10^+/- exponent */
	
	item->valuedouble=n;
	item->valueint=(int)n;
	item->type=cJSON_Number;
	return num;
}
{% endcodeblock %}
为了能看清代码，我对源代码的格式稍微做了调整。同样的，对于数字的解析也是对下图状态机的一个实现，对照图看代码部分很清晰。
{% asset_img "number.gif" "number" %}

`parse_array`函数用于解析数组，其定义如下：
{% codeblock lang:c %}
/* Build an array from input text. */
static const char *parse_array(cJSON *item,const char *value,const char **ep)
{
	/* ... */
	value=skip(parse_value(child,skip(value),ep));	/* skip any spacing, get the value. */
	if (!value) return 0;

	while (*value==',')
	{
		cJSON *new_item;
		if (!(new_item=cJSON_New_Item())) return 0; 	/* memory fail */
		child->next=new_item;new_item->prev=child;child=new_item;
		value=skip(parse_value(child,skip(value+1),ep));
		if (!value) return 0;	/* memory fail */
	}

	if (*value==']') return value+1;	/* end of array */
	*ep=value;return 0;	/* malformed. */
}
{% endcodeblock %}
数组是用于存放别的数据的数据类型，因此对于数组的解析，除了解析`[`和`]`外，剩下的就是对内部value的解析，所以只需要对数组内每一个元素调用`parse_value`即可，从这里也体现出，对json的解析其实是一个递归的过程。数组内的每两个元素之间用`,`隔开，数组内的元素之间是兄弟关系，所以需要指定好他们的前一个节点以及后一个节点的指针。

`parse_object`函数用于解析对象，其定义如下：
{% codeblock lang:c %}
/* Build an object from the text. */
static const char *parse_object(cJSON *item,const char *value,const char **ep)
{
	/* ... */
	value=skip(parse_string(child,skip(value),ep)); /* 解析key的名字 */
	if (!value) return 0;
	child->string=child->valuestring;child->valuestring=0;

	/* 解析key-value间的: */
	if (*value!=':') {*ep=value;return 0;}	/* fail! */
	/* 解析key-value中的value */
	value=skip(parse_value(child,skip(value+1),ep));	/* skip any spacing, get the value. */
	if (!value) return 0;
	
	/* 循环解析key-value pair */
	while (*value==',')
	{
		cJSON *new_item;
		if (!(new_item=cJSON_New_Item()))	return 0; /* memory fail */
		child->next=new_item;new_item->prev=child;child=new_item;
		value=skip(parse_string(child,skip(value+1),ep));
		if (!value) return 0;
		child->string=child->valuestring;child->valuestring=0;
		if (*value!=':') {*ep=value;return 0;}	/* fail! */
		value=skip(parse_value(child,skip(value+1),ep));	/* skip any spacing, get the value. */
		if (!value) return 0;
	}
	
	if (*value=='}') return value+1;	/* end of array */
	*ep=value;return 0;	/* malformed. */
}
{% endcodeblock %}
对象用于存放多个无序的键值对，其中键是string类型，值可以是任意类型。其解析过程同对数组的解析过程类似，首先解析key，因为key是string类型，调用parse_string获得key的名字，接着解析value，调用parse_value。如果有`,`则表明还有key-value对，接着循环解析。
