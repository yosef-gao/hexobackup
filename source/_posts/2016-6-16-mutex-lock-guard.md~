---
title: Mutex Lock Guard
tags:
  - C++
  - linux
categories: Program
author: yosef gao
date: 2016-06-16 13:37:13
---


陈硕老师《Linux 多线程服务端编程 使用muduo C++网络库》一书中对于MutexLock、MutexLockGuard的封装，主要用到了C++中的[RAII技术](/2016/06/14/cpp-raii/)。

<!--more-->

{% codeblock lang:cpp MutexLock.cpp %}
class MutexLock : boost::nocopyable
{
    public:
        MutexLock()
            : holder_(0)
        {
            pthread_mutex_init(&mutex_, NULL);
        }

        ~MutexLock()
        {
            assert(holder_ == 0);
            pthread_mutex_destory(&mutex_);
        }

        bool isLockByThisThread()
        {
            return holder_ == CurrentThread::tid();
        }

        void assertLocked()
        {
            assert(isLockByThisThread());
        }

        void lock() // 仅供MutexLockGuard()调用，严禁用户代码调用
        {
            pthread_mutex_lock(&mutex_);
            holder_ = CurrentThread::tid(); // 这两行顺序不能反
        }

        void unlock()
        {
            holder_ = 0;
            pthread_mutex_unlock(&mutex_); // 这两行顺序不能反
        }

        pthread_mutex_t* getPthreadMutex() // 仅供Codition调用，严禁用户代码调用
        {
            return &mutex_;
        }

    private:
        pthread_mutex_t mutex_;
        pid_t holder_;
};
{% endcodeblock %}

{% codeblock lang:cpp MutexLockGuard.cpp %}
class MutexLockGuard : boost::nocopyable
{
    public:
        explicit MutexLockGuard(MutexLock& mutex)
            :mutex_(mutex)
        {
            mutex_.lock();
        }

        ~MutexLockGuard()
        {
            mutex_.unlock();
        }

    private:
        MutexLock& mutex_;
};

#define MutexLockGuard(x) static_assert(false, "missing mutex guard var name")
{% endcodeblock %}

注意上面代码的最后一行定义了一个宏，这个宏的作用是防止程序里出现如下错误：
{% codeblock lang:cpp test.cpp %}
void doit()
{
    MutexLockGuard(mutex); // 遗漏变量名，产生一个临时的对象又马上销毁了

    // 正确写法是 MutexLockGuard lock(mutex);
    //
    // 临界区
}
{% endcodeblock %}

{% codeblock lang:cpp Condition.cpp%}
class Condition : boost::noncopyable
{
    public:
        explicit Condition(MutexLock& mutex)
            : mutex_(mutex)
        {
            pthread_cond_init(&pcond_, NULL);
        }

        ~Condition()
        {
            pthread_cond_destory(&pcond_);
        }

        void wait() 
        {
            pthread_cond_wait(&pcond_, mutex_.getPthreadMutex());
        }

        void notify()
        {
            pthread_cond_signal(&pcond_);
        }

        void notifyAll()
        {
            pthread_cond_broadcast(&pcond_);
        }

    private:
        MutexLock& mutex_;
        pthread_cond_t pcond;
}
{% endcodeblock %}
