---
title: 简单Linux C线程池的实现
tags:
  - c/c++
  - linux
categories: Linux
author: yosef gao
date: 2016-04-02 12:46:54
---


大多处网络服务器，包括Web服务器都有一个特点，就是单位时间内要处理大量的请求，且处理的时间往往比较短。本文会分析一下多进程网络服务器模型、多线程网络服务器模型（包括线程池）之间的优缺点，并给出一个简单的线程池模型。

<!--more-->

多进程网络服务器模型
--------------------
多进程网络服务器模型，其基本框架往往是，父进程用`socket`创建一个监听套接字，然后`bind`IP以及port，接着开始`listen`该套接字，通过一个while循环来`accept`连接，对于每一个连接，`fork`一个子进程来处理连接，并继续`accept`。简化后的代码如下：

{% codeblock lang:cpp %}
int listenfd, clientfd;
struct sockadd_in servaddr;
listenfd = socket(AF_INET, SOCK_STREAM, 0);

// ...初始化servaddr,填入addr,port等...

bind(listenfd, (struct sockadd \*)&servaddr, sizeof(servaddr));

listen(listenfd, LISTENQ);

pid_t pid;
while (1)
{
    clientfd = accept(listenfd, NULL, NULL);
    pid = fork();
    if (pid == -1)
    {
        // ...出错处理...
        return 0;
    }

    if (pid == 0) // in child
    {
        close(listenfd);
        // handle(clientfd);
        return 0;
    }
    else if (pid > 0) // in parent
    {
        close(clientfd);
    }
}
{% endcodeblock %}

这种模型的缺点也十分明显，我们都知道`fork`一个子进程的代价是很高的，表现在以下几点：
1. 每次进来一个连接，操作系统为其创建一个进程，开销太大。《APUE》书8.3节讲到子进程是父进程的副本，父进程和子进程共享正文段，子进程获得父进数据空间、堆和栈的副本。即便现在现在很多实现通过写时复制(Copy-On-Write,COW)技术来替代完全拷贝，但是其中有一个复制父进程页表的操作，这也是为什么在Linux下创建进程比创建线程开销大的原因，而所有线程都共享一个页表[1]。

2. 进程调度压力大。当并发量上来之后，系统会有N多个进程，这时候操作系统将花费相当多的时间来调度进程以及执行进程的上下文切换。

3. 每个进程都有自己独立的地址空间，需要消耗一定的内存，太多的进程会造成内存的大量消耗。同时，高并发下父子进程之间的IPC也是一个问题。


---------------------------------------------------------------------------------------------------------------------------------------


多线程网络服务器模型
---------------------
多线程网络服务器模型大致同上，不同点在于把每次`accept`一个新连接是创建一个线程而不是进程来处理。然而我们知道web服务器的一个特点就是短而高频率的请求，表现在服务器端就是不停地创建线程，销毁线程。所以该方法虽然在一定程度上解决了`fork`的开销问题，但是同样没有办法避免线程调度开销问题以及内存问题。

一个改进的方法是改用线程池，让线程的数量固定下来，这样就解决了上述问题。其基本架构为用一个`loop`来`accept`连接，之后把这个连接分配给线程池中的一个线程来处理，处理完了之后这个线程回归线程池等待下一次处理连接。从目前来看，该方法已经很好地解决了上面提到的各种问题，文末也会给出该方法的不足以及改进。下面给出一个较为简单的线程池模型。这份threadpool的实现并非我原创的，看到代码条理清楚，清晰易懂，就转载过来了[2]。

{% codeblock threadpool.h lang:cpp %}
#ifndef _THREAD_POOL_H_
#define _THREAD_POOL_H_

#include <pthread.h>

typedef void *(*callback_func)(void*);

typedef struct job
{
    callback_func p_callback_func;          // 线程回调函数
    void *arg;
    struct job *next;
} job_t;

typedef struct threadpool
{
    int thread_num;                         // 线程池中开启线程的个数
    int queue_max_num;                      // 队列中最大job的个数
    job_t *head;                            // 指向job的头指针
    job_t *tail;                            // 指向job的尾指针
    pthread_t *pthreads;                    // 线程池中所有线程的pthread_t
    pthread_mutex_t mutex;                  // 互斥信号量
    pthread_cond_t queue_empty;             // 队列为空的条件变量
    pthread_cond_t queue_not_empty;         // 队列不为空的条件变量
    pthread_cond_t queue_not_full;          // 队列不为滿的条件变量
    int queue_cur_num;                      // 队列当前的job个数
    int queue_close;                        // 队列是否已经关闭
    int pool_close;                         // 线程池是否已经关闭
} threadpool_t;

/*
 * pthreadpool_init - 初始化线程池
 * @thread_num - 线程池开启的线程个数
 * @queue_max_num - 队列的最大job个数
 * 返回 - 成功返回线程池地址 失败返回NULL
 * */
threadpool_t *threadpool_init(int thread_num, int queue_max_num);

/*
 * threadpool_add_job - 想线程池中添加任务
 * @pool - 线程池地址
 * @callback_function - 回调函数
 * @arg - 回调函数参数
 * 返回 - 成功返回0 失败返回-1
 * */
int threadpool_add_job(threadpool_t *pool, callback_func p_callback_fun, void *arg);

/*
 * threadpool_destory - 销毁线程池
 * @pool - 线程池地址
 * 返回 - 永远返回0
 * */
int threadpool_destory(threadpool_t *pool);

/*
 * threadpool_function - 线程池中线程函数
 * @arg - 线程池地址
 * */
void *threadpool_function(void *arg);

#endif /* _THREAD_POOL_H_ */
{% endcodeblock %}

{% codeblock threadpool.c lang:cpp %}
#include "threadpool.h"
#include "common.h"

threadpool_t *threadpool_init(int thread_num, int queue_max_num)
{
    threadpool_t *pool = NULL;
    pool = malloc(sizeof(threadpool_t));
    do
    {
        if (NULL == pool)
        {
            bug("failed to malloc threadpool\n");
            break;
        }
        pool->thread_num = thread_num;
        pool->queue_max_num = queue_max_num;
        pool->queue_cur_num = 0;
        pool->head = NULL;
        pool->tail = NULL;

        if (pthread_mutex_init(&(pool->mutex), NULL))
        {
            bug("pthread_mutex_init\n");
            break;
        }
        if (pthread_cond_init(&(pool->queue_empty), NULL))
        {
            bug("pthread_cond_init\n");
            break;
        }
        if (pthread_cond_init(&(pool->queue_not_empty), NULL))
        {
            bug("pthread_cond_init\n");
            break;
        }
        if (pthread_cond_init(&(pool->queue_not_full), NULL))
        {
            bug("pthread_cond_init\n");
            break;
        }

        pool->pthreads = malloc(sizeof(pthread_t) * thread_num); 
        if (NULL == pool->pthreads)
        {
            bug("malloc error\n");
            break;
        }
        
        pool->queue_close = 0;
        pool->pool_close = 0;

        int i;
        for (i = 0; i < pool->thread_num; ++i)
        {
            if (pthread_create(&(pool->pthreads[i]), NULL, threadpool_function, (void *)pool) < 0)
                bug("pthread_create\n");
        }

        return pool;
    } while (0);

    return NULL;
}

int threadpool_add_job(threadpool_t *pool, callback_func p_callback_func, void *arg)
{
    if (pool == NULL || p_callback_func == NULL)
        return -1;

    pthread_mutex_lock(&(pool->mutex));
    while ((pool->queue_cur_num == pool->queue_max_num) && !(pool->pool_close || pool->queue_close))
    {
        // 等待threadpool_function发送queue_not_full信号
        pthread_cond_wait(&(pool->queue_not_full), &(pool->mutex)); // 队列满的时候就等待
    }
    if (pool->queue_close || pool->pool_close) // 队列关闭或者线程池关闭就退出
    {
        pthread_mutex_unlock(&(pool->mutex));
        return -1;
    }
    job_t *pjob = (job_t *)malloc(sizeof(job_t));
    if (NULL == pjob)
    {
        pthread_mutex_unlock(&(pool->mutex));
        return -1;
    }
    pjob->p_callback_func = p_callback_func;
    pjob->arg = arg;
    pjob->next = NULL;

    if (pool->head == NULL)
    {
        pool->head = pool->tail = pjob;
        pthread_cond_broadcast(&(pool->queue_not_empty)); // 队列空的时候，有任务来了，就通知线程池中的线程：队列非空
    }
    else
    {
        pool->tail->next = pjob;
        pool->tail = pjob; // 把任务插入到队列的尾部
    }
    pool->queue_cur_num++;
    pthread_mutex_unlock(&(pool->mutex));

    return 0;
}

void *threadpool_function(void *arg)
{
    threadpool_t *pool = (threadpool_t *)arg;
    job_t *pjob = NULL;

    while (1)
    {
        pthread_mutex_lock(&(pool->mutex));
        while ((pool->queue_cur_num == 0) && !pool->pool_close) // 队列为空，就等待队列非空
        {
            // 等待threadpool_add_job函数发送queue_not_empty信号
            pthread_cond_wait(&(pool->queue_not_empty), &(pool->mutex));
        }
        if (pool->pool_close) // 线程池关闭，线程就退出
        {
            pthread_mutex_unlock(&(pool->mutex));
            pthread_exit(NULL);
        }
        pool->queue_cur_num--;
        pjob = pool->head;
        if (pool->queue_cur_num == 0)
        {
            pool->head = pool->tail = NULL;
        }
        else
        {
            pool->head = pjob->next;
        }

        if (pool->queue_cur_num == 0)
        {
            pthread_cond_signal(&(pool->queue_empty)); // 通知destory函数可以销毁线程池了
        }
        else if (pool->queue_cur_num <= pool->queue_max_num - 1)
        {
            // 向threadpool_add_job发送queue_not_full信号
            pthread_cond_broadcast(&(pool->queue_not_full));
        }

        pthread_mutex_unlock(&(pool->mutex));

        (*(pjob->p_callback_func))(pjob->arg); // 线程真正要做的工作，调用回调函数
        free(pjob);
        pjob = NULL;
    }
}

int threadpool_destory(threadpool_t *pool)
{
    if (pool == NULL)
        return 0;

    pthread_mutex_lock(&(pool->mutex));
    if (pool->queue_close && pool->pool_close) // 线程池已经退出了，就直接返回
    {
        pthread_mutex_unlock(&(pool->mutex));
        return 0;
    }

    pool->queue_close = 1; // 关闭任务队列，不接受新的任务了
    while (pool->queue_cur_num != 0)
    {
        pthread_cond_wait(&(pool->queue_empty), &(pool->mutex)); // 等待队列为空
    }

    pool->pool_close = 1; // 线程池关闭
    pthread_mutex_unlock(&(pool->mutex));
    pthread_cond_broadcast(&(pool->queue_not_empty)); // 唤醒线程池中正在阻塞的线程
    pthread_cond_broadcast(&(pool->queue_not_full)); // 唤醒添加任务的threadpool_add_job函数

    int i;
    for (i = 0; i < pool->thread_num; ++i)
    {
        pthread_join(pool->pthreads[i], NULL); // 等待线程池的所有线程执行完毕
    }

    pthread_mutex_destroy(&(pool->mutex)); // 清理资源
    pthread_cond_destroy(&(pool->queue_empty)); 
    pthread_cond_destroy(&(pool->queue_not_empty)); 
    pthread_cond_destroy(&(pool->queue_not_full)); 
    free(pool->pthreads);

    job_t *pjob;
    while (pool->head != NULL)
    {
        pjob = pool->head;
        pool->head = pjob->next;
        free(pjob);
    }
    free(pool);
    return 0;
}
{% endcodeblock %}

--------------------------------------------------------------

剩余问题
---------
线程池的方案虽然看起来很不错，但在实际情况中，很多连接都是长连接（在一个TCP连接上进行多次通信），一个线程在受到任务以后，处理完第一批来的数据，此时会再次调用`read`，但是客户端下一次发送数据过来的时机是不确定的，于是这个线程就被这个read给阻塞住了（socket
fd默认是blocking的）,直到1.这个fd可读者；2.对方已经关闭连接；3.TCP超时这3个情况之一发生之前什么都不能干，那么并发量上来之后还是会发生部分连接无法被即使处理的情况。

一个比较好的解决方案是把fd 设置为non-blocking,并通过事件驱动（Event-driven）的方法来处理连接，在linux下可以通过epoll实现。关于epoll目前还在学习当中。一个较为完整的实现可以参考引用2中给出的链接。

Reference
-------------
[1] http://lifeofzjs.com/blog/2015/05/16/how-to-write-a-server/
[2] http://www.cnblogs.com/venow/archive/2012/11/22/2779667.html
