# Chp12 Concurrent Programming

concurrency并发: 很广义的概念, 任务在逻辑控制时间上重叠, 则它们是并发的. 在exception, process和Linux signal上运用

应用程序中的并发: 不仅仅局限于内核处理多个程序进程. 例如应用程序中有Linux Signal Handler运行应用异步响应Signal. 其意义有:

- 慢速I/O Access: 应用访问慢速IO时, 内核调度运行其他程序.  程序内也可以用类似的方式并行IO和其他事物
- 与人交互: 用户请求操作时, 需要创建一个独立的并发逻辑流来执行操作
- 推迟工作来降低延迟: 推迟一些操作, 并发执行它们来降低操作延迟
- 服务多个网络客户端
- 多核机器上进行并行运算

含有应用级别的并发控制流的程序为并发程序. OS提供三种方法实现:

- 进程Process: 每个逻辑控制流作为一个进城, 由系统内核来调度和维护. 其地址空间相互独立, 需要通过显示的IPC(Interprocess communication)机制
- I/O multiplexing 多路复用: 逻辑流为状态机被主进程转化, 共享文件数据和地址空间
- 现成Threads: 线程是运行在一个单一进程context的逻辑流, 有内核调度. 共享虚拟地址空间 

## 1. Concurrent Programming with Processes

以echoServer为例

利用进程构造并发服务器, 在父进程中接收client的连接请求, 再创建一个子进程来为每个client提供服务. 

![image-20190621213113566](Chp12ConcurrentProgramming.assets/image-20190621213113566.png)

1. Server端,有int connfd1 = accept(listenedfd, …, …)

   ![image-20190621213628250](Chp12ConcurrentProgramming.assets/image-20190621213628250.png)

2. Server派生一个子进程Servelet, 获得主进程全部的fd副本. 子进程关闭listenedfd, 主进程关闭connfd1, 子进程处理业务echo(connfd1);

   主进程应当关闭connfd. 服务转换后关闭由子进程完成, 主进程会造成内存泄漏

   ![image-20190621214352076](Chp12ConcurrentProgramming.assets/image-20190621214352076.png)

3. Server端接收新的client链接请求 int connfd2 = accept(listenedfd, … ,… ). 

   ![image-20190621214545928](Chp12ConcurrentProgramming.assets/image-20190621214545928.png)

4. 主进程派生另一个子进程, 利用connfd2来为客户提供业务端服务echo(connfd2). 此时Server主进程等待下一个请求, 两个子进程并发为客户端提供业务服务

### 1.1 A Concurrent Server Based on Processes

implementation

```c
int main(int argc, char **argv) 
{
   int listenfd, connfd;
   struct sockaddr_in clientaddr;
   socklen_t clientlen = sizeof(clientaddr);

   Signal(SIGCHLD, sigchld_handler);
   listenfd = Open_listenfd(argv[1]);
   while (1) {
      connfd = Accept(listenfd, (SA *) &clientaddr, &clientlen);
      if (Fork() == 0) { 
         Close(listenfd); 
         echo(connfd);    
         Close(connfd);   
         exit(0);         
      }
      Close(connfd);
   }
}

void sigchld_handler(int sig) 
{
   while (waitpid(-1, 0, WNOHANG) > 0)
	;
   return;
}
```

- void sigchld_handler(int sig)用来回收多个zombie进程, 避免长时间的server运行时间占用资源
- 主进程, 子进程必须关闭各自的connfd副本, 避免内存泄漏
- socket file table中每一项具有reference count, 直到主进程和子进程的connfd都关闭后连接client的socket才会终止

### 1.2 Pros and Cons of Processes

- 父子进程共享资源: shard file table. 
- 不共享资源: 地址空间. 独立性强, 但是共享状态信息变得困难. 必须使用IPC机制, 效率慢, 因为进程控制和IPC的开销很高

## 2. Concurrent Programming with I/O Multiplexing

响应客户端的键入, 则必须响应两个独立的I/O事件:

- 客户端的socket连接请求
- 客户端的键入命令

I/O Multiplexing: 使用select函数, 要求内核挂起进程, 在一个或多个IO事件发生后再返回控制给进程

## 3. Concurrent Programming with Threads

Thread: 运行在进程上下文中的逻辑流. 

- 一般的进程只有一个线程. 
- 不同线程之间由内核调度.
- 每个线程也有自己的thread context, 包括唯一的thread ID, tid, 栈, rsp, pc, regs和cc. 
- 所有运行在一个进程的线程共享整个该进程的虚拟地指空间

![image-20190622000511025](Chp12ConcurrentProgramming.assets/image-20190622000511025.png)

### 3.1  Thread Execution Model

主线程创建对等线程后, 二者并发运行. 控制权在二者之间交接

![image-20190622001109111](Chp12ConcurrentProgramming.assets/image-20190622001109111.png)

线程切换与进程切换不同:

- thread context 比 process context小得多, 切换更快

- 线程没有严格的父子层次, 与进程相关的线程组成一个线程池

  ![image-20190622000354455](Chp12ConcurrentProgramming.assets/image-20190622000354455.png)

- 主线程总是第一个运行的线程

- 同一个线程池中的线程可以杀死任何对等线程, 或者等待对等线程终止

- 每个对等线程都能读写相同的共享数据

### 3.2 Posix Treads

Posix Threads = Pthreads 是C中使用的一个标准接口, 在所有的Linux系统上可用.

Pthreads定义大约60个函数, 允许程序创建, 杀死, 回收线程, 与对等线程安全地共享数据, 通知对等线程状态变化

```c
/* hello.c - Pthreads "hello, world" program */
#include "csapp.h"

/* thread routine */
void *thread(void *vargp) {
  printf("Hello, world!\n"); 
  return NULL;
}

int main() {
  pthread_t tid;
  Pthread_create(&tid, NULL, thread, NULL);
  Pthread_join(tid, NULL);
  exit(0);
}
```

![image-20190622003047047](Chp12ConcurrentProgramming.assets/image-20190622003047047.png)

- 主线程通过exit回收这个进程中的所有线程
- 线程的代码和本地数据封装在thread routine里
- 线程例程接收一个通用指针作为输入, 参数被放入指针指向的地址中
- 线程例程返回通用指针作为结果

### 3.3 Creating Threads

```c
#include <pthreads.h>
typedef void *(func)(void*);
int pthead_create(pthread_t *tid,
                  pthread_attr_t *attr,
                  void *(*f)(void*),
                 	void *arg);
pthread_t pthread_self(void);
```

``pthreads_create`` 用来创建一个新的例程, 成功则返回0

- ``tid``: 存储例程ID
- ``attr``: 线程创建的默认属性, 一般用NULL
- ``f``: 线程例程指针
- ``arg``: 传入例程参数指针
- ``pthread_self(void)``: 获取线程自身tid

### 3.4 Terminating Threads

- 顶层的线程例程返回时, 线程隐式地终止
- 调用``pthread_exit``函数, 线程显示地终止
  - 主线程调用则等待所有其他线程终止, 探后再终止主线程和整个进程, 返回``thread_return``
- 对等线程内调用Linux的``exit``函数, 则终止与该进程所有相关的线程
- 对等线程以一个tid为参数, 调用``pthread_cancel``来终止线程

```c
#include <pthread.h>
void pthread_exit(void *thread_return);
int pthread_cancel(pthread_t tid);
```

### 3.5 Reaping Terminated Threads

通过``pthread_join``函数等待其他线程终止

```c
#include <pthread.h>
int pthread_join(pthread_t tid, void **thread_return);
```

- ``pthread_join``会阻塞caller, 直到tid终止.
- 线程例程返回的通用指针赋值为``thread_return``指向的位置, 回收线程占优的内存资源
- ``pthread_join``只能等待一个指定线程的终止, 与Linux的``wait``不同

### 3.6 Detaching Threads

任何时刻, 线程都是joinable或者detached的.

- joinable的线程可以被其他线程杀死或者回收. 
  - 在线程被回收之前, 其内存资源不释放
- detached线程不能被杀死和回收
  - 资源在其终止时由系统自动释放
- 默认线程是joinable的, 为了避免内存泄漏
  - 所有joinable的线程都要被其他线程显式地回收
  - 或者调用``pthread_detach``函数被分离

```c
#include <pthread.h>
int pthread_detach(pthread_t tid);
```

``pthread_detach``函数分离joinable线程tid, tid可以是从``pthread_self``获取的自身

- 当线程不需要被其他线程显式地等待回收时, 应该被分离来保证内存资源不泄露

### 3.7 Initializing Threads

- 允许初始化与线程相关的状态

```c
#include <pthread.h>
pthread_once_t once_control = PTHREAD_ONCE_INIT;
int pthread_once(pthread_once_t *once_control,
                 void (*init_routine)void);
```

- ``once_control``变量是全局或者静态的, 总被初始化为PTHRED_ONCE_INIT
- 第一次用参数``once_control``调用``pthread_once``时, 会调用``init_routine``
- ``init_routine``是一个无参数, 无返回的函数
- 接下来, ``pthread_once``不做任何事情
- 需要动态初始化多个线程共享的全局变量时可以调用

### 3.8 A Concurrent Server Based on Threads

主线程不断等待并Accept链接请求, 创建对等线程服务请求

```c
int main(int argc, char **argv){
    int listenfd, *connfdp
    socklen_t clientlen;
    struct sockaddr_in clientaddr;
    pthread_t tid;

    if (argc != 2) {
        fprintf(stderr, "usage: %s <port>\n", argv[0]);
        exit(0);
    }
    listenfd = open_listenfd(argv[1]);
    while (1) {
        clientlen = sizeof(clientaddr);
        connfdp = Malloc(sizeof(int));
        *connfdp = Accept(listenfd,
                          (SA *)&clientaddr,
                          &clientlen);
        Pthread_create(&tid, NULL, thread, connfdp);
    }
}

/* thread routine */
void *thread(void *vargp)
{
    int connfd = *((int *)vargp);

    Pthread_detach(pthread_self());
    Free(vargp);
    echo(connfd);
    Close(connfd);
    return NULL;
}
```

- 调用``pthread_create``时, 通过connfdp(malloc的堆空间)将已连接的descriptor传递给线程

  - 不能使用栈空间, 如

    ```c
    int main() {
    	...
      while(1){
    	  int connfd = Accept(listenedfd, ...);
    		Pthread_create(&tid, NULL, thread, &connfd);
        ...
      }
      ...
    }
    
    void *thread(void *vargp){
      int connfd = *((int *)vargp);
      ...
    }
    ```

    这种参数传递引起了例程中的参数赋值(line12)和主线程accept(line3)之间的竞争

    - 赋值语句在下一次accept之前完成, 例程中的connfd为正确值.
    - 赋值语句在下一次(几次)accept之后完成, 则例程中得到是那一次的connfd
      - 导致两个线程在一个descriptor输入和输出

    accept得到的descriptor要求放到属于其自己的动态分配的堆空间中.

  - 主线程没有显式回收线程, 线程例程中必须分离自身, 在终止时避免内存泄漏. ``pthread_detach(pthread_self())``

  - 例程负责释放主线程中分配的参数占用的堆内存. `` free(vargp)``

## 4. Shared Variables in Threads Programs

- 线程的基础内存模型
- 变量实例如何映射到内存
- 线程实例引用这些示例

![image-20190622164258013](Chp12ConcurrentProgramming.assets/image-20190622164258013.png)

### 4.1 Threads Memory Model

- 一组线程运行在一个进程的上下文中, 共享
  - 虚拟地址空间
  - 代码段
  - 读写数据段
  - 堆空间
  - 共享库代码
  - 打开的文件集合
- 每个线程有自己的独立线程上下文, 包括
  - 线程ID
  - 栈
  - 栈指针
  - PC
  - CC
  - regs
- 寄存器从不共享, 内存总是共享
- 线程栈的内存模型:
  - 被保存在虚拟地址的栈区域中
  - 通常由对应的线程独立访问
    - 线程栈不对其他线程设防, 可以读写其他栈的任何部分

```c
#include "csapp.h"
#define N 2
void *thread(void *vargp);

char **ptr; 
/* global variable */
int main()
{
	int i;
 	pthread_t tid;
  char *msgs[N] = {
 	  "Hello from foo",
 	  "Hello from bar"
	};

 	ptr = msgs;
 	for (i = 0; i < N; i++)
 	   Pthread_create(&tid, NULL, thread, (void *)i);
 	Pthread_exit(NULL);
}

void *thread(void *vargp)
{
 	int myid = (int)vargp;
 	static int cnt = 0;
 	printf("[%d]:%s(cnt=%d)\n", myid, ptr[myid], ++cnt);
}
```

line26表现了对等线程通过全局变量ptr简介访问了主线程栈上的内容(msgs)

### 4.2 Mapping Variables to Memory

多线程C程序根据变量的存储类型映射到虚拟内存

- 全局变量Global variables: 虚存的read/write区域只包含每个全局变量的一个实例, 任何线程都可以引用

  (如line5 ptr)

- 本地自动变量Local automic variables: 运行时, 没个线程都在自己的运行时栈上实例化本地自动变量. 多线程则多次实例化.

  如本地变量myid(line24)有两个实例: 0号对等线程和1号对等线程的栈上. 分别记为myid.p0和myid.p1

- 本地静态变量 Local static variables: 同全局变量一样, 实例化在虚存的read/write区域

  如cnt(line25)

### 4.3 Shared Variables

变量的一个实例被一个以上的线程引用

- cnt: 共享的静态变量
- msgs: 共享的本地自动变量
- myid: 不是共享变量

## 5. Synchronizing Threads with Semaphores

```c
#include "csapp.h"
#define NITERS 100000000
void *count(void *arg);

/* shared variable */
unsigned int cnt = 0;

int main()
{
 	pthread_t tid1, tid2;

 	Pthread_create(&tid1, NULL, count, NULL);
 	Pthread_create(&tid2, NULL, count, NULL);
 	Pthread_join(tid1, NULL);
 	Pthread_join(tid2, NULL);

 	if (cnt != (unsigned)NITERS*2)
 	    printf("BOOM! cnt=%d\n", cnt);
 	else
 	    printf("OK cnt=%d\n", cnt);
 	exit(0);
}

/* thread routine */
void *count(void *arg)
{
 	int i;
 	for (i=0; i<NITERS; i++)
 	    cnt++;
 	return NULL;
}
```

创建两个线程, 每个线程对共享变量cnt增加NITERS次, 线程都运行完毕后, cnt != 2×NITERS. 分析线程例程的汇编代码:

![image-20190622200940109](Chp12ConcurrentProgramming.assets/image-20190622200940109.png)

- H~i~: 循环头部的指令. 在主线程栈上读取niters到%rcx并判断; %rax置零
- L~i~: 加载共享变量```cnt```到寄存器%rdx~i~
- U~i~: 寄存器%rdx~i~数值更新, 增加1
- S~i~: 将%rdx~i~更新后的值写回共享变量cnt中
- T~i~: 循环尾部的指令. 循环检查

并发执行会按所有拓扑排序执行不同线程例程中的指令. 其中一些拓扑顺序会产生错误的结果:

- 无法保证OS执行了正确的顺序
- 当出现两个进程Load到同一个cnt并先后写回是, 导致其中一次incq无效

![image-20190622203558733](Chp12ConcurrentProgramming.assets/image-20190622203558733.png)

### 5.1 Progress Graphs

进度图: 将n个并发线程执行模型转化为一条==n维度笛卡尔空间中的轨迹线==

- 每条轴k对应于线程k的进度(执行到第几条指令)
- 每个点代表线程k已经完成了I~k~这一条指令
- 原点对应于没有线程完成任何指令的初始状态
- 指令执行模型转化为状态之间的转换transition, 为从一点到相邻点的有向边
- 合法转换只能是指向右或向上的, 不允许对角和反向

对于一个线程, 操作共享变量的指令构成一个关于该变量的临界区 ==Critical section==

- 临界区内不能和其他进程交替执行
- 确保每个线程在执行临界区中的指令时, 拥有对共享变量的互斥访问 mutual exclusion
- 两个临界区的交集形成不安全区usafe region
- 不安全区是个开区间
- 绕开不安全区的轨迹是安全轨迹
- 接触到安全区内部的轨迹是不安全轨迹
- 安全轨迹是能够正确更新共享变量的

为了保证共享数据结构的并发程序能够正确执行, 必须用一种方式来同步线程, 保证运行在一条安全轨迹上.

![image-20190622213109946](Chp12ConcurrentProgramming.assets/image-20190622213109946.png)

### 5.2 Semaphores

Semaphore: 一种特殊类型的变量. 信号量s是具有非负整数值的全局变量, 只能通过P和V两种操作处理:

- P(s)
  - s非零, P将s减一, 立即返回(不阻塞)
  - s为0, 挂起caller线程, 直到s变为非零(一个V操作会重启改线程)
  - 重启后, P将s减一并返回给caller线程
- V(s)
  - V操作将s加一
  - 如果有若干线程被P操作阻塞, 等待s变成非零的. 则V启动这些线程中的一个
  - 启动后该线程的P将s减一, 返回caller

```pseudocode
P(s): [ while (s == 0) wait(); s--; ]
V(s): [ s++; ]
```



- P中的s测试和减一操作是不可分割的. 一旦测试到s非零, 就会减一(一条指令)
- V中的s测试和加一操作也是不可分的
- V中没有定义阻塞线程的启动顺序, 这也是programmer不可预设的
- P和V的定义保证了一个运行时的程序不会进入一个负值Semaphore的状态, 称为==Semaphore invariant==

Posix标准定义的Semaphore操作函数

```c
#include <semaphore.h>
int sem_init(sem_t *sem, 0, unsigned int value);
int sem_wait(sem_t *s); /* P(s) */
int sem_post(sem_t *s); /* V(s) */
```

- ``sem_init``: 将Semaphore sem初始化为value, Semaphore在使用前必须初始化.

### 5.3 Using Semaphores for Mutual Exclusion

- 将每个共享变量和一个Semaphore(初始值为1)关联起来, 利用P和V将对共享操变量的操作包围起来, 以实现保护共享变量的读写串行化. 

- 这种Semaphore称为 binary semaphore. 一位其值总是0或1
- 以互斥为目的binary semaphore也成为互斥锁 mutex
  - P可以看做是给共享变量加上mutex
  - V可以看做是给共享变量解除mutex
- 一组可用资源的计数器Semaphore叫做counting semaphore

![image-20190623000942920](Chp12ConcurrentProgramming.assets/image-20190623000942920.png)

- 利用PV操作结合创建一组状态 — Forbidden region
  - FR内部s < 0, 有Semaphore Invariant可知没有轨迹线会接触FR
  - FR完全包含了unsafe region, 所以实际轨迹是绝对安全的
  - 任何时间点, 不可能有多个线程在都在Critical region(L.U.S.)执行, semaphore保证了C.R.访问的互斥

```c
#include <semaphore.h>
volatile long cnt = 0; 
sem_t mutex;
/* in main thread */
...
	Sem_init(&mutex, 0, 1);
...
/* in critical region */
...
  for(i = 0; i < niters; i++) {
    P(&mutex);
    cnt++;
    V(&mutex);
  }
...
```

### 5.4 Using Semaphores to Schedule Shared Resource

一个线程用semaphore来通知另一个线程, 程序状态中某个条件已经成立了

#### Producer-Consumer Problem

![image-20190623153611039](Chp12ConcurrentProgramming.assets/image-20190623153611039.png)

Producer和Consumer共享有n个slots的buffer.

- Producer反复生成新的item, 插入到buffer中
- Consumer不断地从buffer取出这些item, 然后使用
- 插入和取出items都涉及更新共享变量, 所以必须保证对buffer的访问是互斥的
- 还需要调度对buffer的访问
  - buffer为满的话, Producer必须等待一个slot为空
  - buffer为空的话, Consumer必须等待一个item到来

##### SBUF Package

sbuf_t

```c
struct {
  int *buf;     /* Buffer array */
  int n;	      /* Maximum number of slots */
  int front;    /* buf[(front+1)%n] is the first item */
  int rear;	    /* buf[rear%n] is the last item */
  sem_t mutex;  /* protects accesses to buf */
  sem_t slots;  /* Counts available slots */
  sem_t items;  /* Counts available items */
} sbuf_t;
```

- items存放在动态分配的``n``项整数数字``buf``中

- ``front``和``rear``是数组第一项和最后一项的索引

- 三个Semaphores``mutex`` ``slots`` ``items``同步对buffer的访问

  - ``mutex``: 提供互斥buffer访问
  - ``slots``: 记录空slots数量
  - ``items``: 记录可用items的数量

- sbuf_init

  ```c
  void sbuf_init(sbuf_t *sp, int n)
  {
      sp->buf = Calloc(n, sizeof(int));
      /* Buffer holds max of n items */
      sp->n = n;
      /* Empty buffer iff front == rear */    
      sp->front = sp->rear = 0;		
      /* Binary semaphore for locking */
      Sem_init(&sp->mutex, 0, 1);
      /* Initially, buf has n empty slots */
      Sem_init(&sp->slots, 0, n);	
      /* Initially, buf has zero data items */
      Sem_init(&sp->items, 0, 0);	
  }
  ```

  - 用``calloc``为buffer分配堆内存
  - ``front`` ``rear``设置为0表示空buffer
  - 为Semaphores赋初值: 1, n, 0

- sbuf_def

  ```c
  void sbuf_define(sbuf_t *sp) 
  {
    Free(sp->buf);
  }
  ```

  - 使用完buffer后释放

- sbuf_insert

  ```c
  void sbuf_insert(sbuf_t *sp, int item)
  {
      /* Wait for available slot */
      P(&sp->slots);
      /*Lock the buffer */
      P(&sp->mutex);
      /*Insert the item */
      sp->buf[(++sp->rear)%(sp->n)] = item;
      /* Unlock the buffer */
      V(&sp->mutex);
      /* Announce available items*/
      V(&sp->items);
  }
  ```

  - 向Buffer中添加item
    - 等待一个可用的slot
    - 加互斥锁
    - 添加项目到Buffer队尾(或者之前的空余)
    - 解除互斥锁
    - 宣布加入的item可用

- sbuf_remove

  ```c
  int sbuf_remove(sbuf_t *sp)
  {
      int item;
      /* Wait for available item */
      P(&sp->items);
      /*Lock the buffer */			
      P(&sp->mutex);
      /*Remove the item */
      item = sp->buf[(++sp->front)%(sp->n)];
      /* Unlock the buffer */
      V(&sp->mutex);			
      /* Announce available slot*/ 	
      V(&sp->slots);			
      return item;
  }
  ```

  - 向buffer中取出一个item
    - 等待一个可用的item
    - 加互斥锁
    - 从Buffer的front位取出item
    - 解除互斥锁
    - 宣布新的空slot可用

#### Readers-Writers Problem

互斥问题的概括: 并发线程访问一个共享对象 (主存中的数据结构, 数据库)

有的线程只读对象(reader), 有的只修改对象(writer)

Writer补习拥有对象的独占反问权, Reader可以和其他reader共享对象.

- 第一类RW问题: 读者优先, 不会有writer阻塞reader
- 第二类RW问题: 写者优先, 写者尽快完成写操作, 可以阻塞reader

```c
int readcnt;    /* Initially 0 */
sem_t mutex, w; /* Both initially 1 */

void reader(void) {
  while (1) {
    P(&mutex);
    readcnt++;
    if (readcnt == 1) /* First in */
      P(&w);
    V(&mutex);
    /* Reading happens here */
    P(&mutex);
    readcnt--;
    if (readcnt == 0) /* Last out */
      V(&w);
    V(&mutex);
  }
}
void writer(void) 
{
  while (1) {
    P(&w);
    /* Writing here */ 
    V(&w);
  }
}
```

- semaphore w 控制对共享对象的critical region的访问

- mutex 保护对共享变量readcnt的访问

- readcnt统计当前critical region中的reader数量

- 当有writer进入critical region时,  对w加锁, 离开对w解锁, 保证writer的唯一性

- 只有第一个reader进入critical region时, 才对w加锁, 最后一个reader离开才解锁

  只要有一个reader在访问, 其他reader都可以忽略互斥锁w

- 这种实现会导致starvation: reader不断到达会导致writer无限期等待

- 上述的优先写是弱实现, 当多个写任务不断到达, 读任务无法开启

### 5.5 A Concurrent Server Based on Prethreading

![image-20190623212021461](Chp12ConcurrentProgramming.assets/image-20190623212021461.png)

- Server由一个主线程和一组工作线程组成
  - 主线程接收client的连接请求, 将建立连接的descriptor放入buffer
  - 每一个worker thread反复从buffer中取出descriptor, 并服务. 之后等待下一个

```c
#include “csapp.h”
#include “sbuf.h”
#define NTHREADS  4
#define SBUFSIZE  16
 
sbuf_t sbuf ; 	/* shared buffer of connected descriptors */ 

int main(int argc, char **argv)
{
    int i, listenfd, connfd;
    sockelen_t clientlen ;  
    struct sockaddr_storage clientaddr;
    pthread_t tid;
   
    if (argc != 2) {
        fprintf(stderr, “usage: %s <port>\n”, argv[0]) ;
        exit(0);
    }
    listenfd = open_listenfd(argv[1]);
    sbuf_init(&sbuf, SBUFSIZE);
    for (i = 0; i < NTHREADS; i++)
      	/* Create worker threads */
        Pthread_create(&tid, NULL, thread, NULL);

    while (1) {
        clientlen =  sizeof(struct sockaddr_storage);
        connfd = Accept (listenfd, 
                         (SA *)&clientaddr,
                         &clientlen);
	      /* Insert connfd in buffer */
        sbuf_insert(&sbuf, connfd);  
    }
}
void *thread(void *vargp)
{
    Pthread_detach(pthread_self());
    while (1) {
      	/* Remove connfd from buffer */
        int connfd = sbuf_remove(&sbuf);
      	/* Service client */
        echo_cnt(connfd);		
        Close(connfd);
    }
}
```

- 主线程初始化sbuf
- 主线程创建一组worker threads
- 主线程循环处理请求, 建立连接, 并将连接后的descriptor放进sbuf中
- worker threads从sbuf中取出一个descriptor, 服务关闭

```c
#include “csapp.h”
 
static int byte_cnt;	/* byte counter */
static sem_t mutex;	/* and the mutex that protects it */
 
static void init_echo_cnt(void)
{
    Sem_init(&mutex, 0, 1);
    byte_cnt = 0;
}
void echo_cnt(int connfd)
{
    int n; 
    char buf[MAXLINE]; 
    rio_t rio;
    static pthread_once_t once = PTHREAD_ONCE_INIT;

    Pthread_once(&once, init_echo_cnt);
    Rio_readinitb(&rio, connfd);
    while((n = Rio_readlineb(&rio, buf, MAXLINE)) != 0) {
        P(&mutex);
        byte_cnt += n;
        printf(“server received %d(%d) byte on fd %d\n”, 
               	n,byte_cnt, connfd);
        V(&mutex);
        Rio_writen(confd, buf, n);
    }
 }
```

从例程调用初始化到程序包的一般技术

- 初始化byte_cnt计数器和mutex互斥锁
  - 用SBUF和RIO包内的初始化函数
  - 用pthread_once函数调用初始化函数

## 6. Using Threads for Parallelism

![image-20190623220330432](Chp12ConcurrentProgramming.assets/image-20190623220330432.png)

- 顺序程序: 一条逻辑流
- 并发程序: 多条并发流
  - 并行程序: 运行在多个处理器上的并发程序

### Threads Closed-form Verifying

主线程

```c
#include "csapp.h"
#define MAXTHREADS 32

void *sum_mutex(void *vargp);  /* Thread routine */

/* Global shared variables */
long gsum; 		/* Global sum */
/* Number of elements summed by each thread */
long nelems_per_thread;	
sem_t mutex ;		/* Mutex to protect global sum */
 
int main(int argc, char **argv)
{
	long i, nelems, log_nelems, nthreads, myid[MAXTHREADS];
	pthread_t tid[MAXTHREADS];

	/* Get input arguments */
	if (argc != 3) {
		printf("Usage: %s <nthreads> <log_nelems>\n", argv[0]); 	   
    exit(0);
	}
 	nthreads = atoi(argv[1]);
	log_nelems = atoi(argv[2]);
 	nelems = (1L << log_nelems);
 	nelems_per_thread = nelems / nthreads;
	sem_init(&mutex, 0, 1);

 	/* Create peer threads and wait for them to finish */
 	for (i = 0; i < nthreads; i++) {
		myid[i] = i;
		Pthread_create(&tid[i], NULL, sum_mutex, &myid[i]);
	}
 	for (i = 0; i < nthreads; i++)
 		Pthread_join(tid[i], NULL);

 	/* Check final answer */
 	if (gsum != (nelems * (nelems-1))/2)
		printf("Error: result=%ld\n", gsum);

 	exit(0);
}
```

#### V1: 

线程例程更新带有互斥锁mutex全局共享变量

```c
/* Thread routine for psum-mutex.c*/
void *sum_mutex(void *vargp)
{
 	int myid = *((int *)vargp); 		/* Extract the thread ID */
 	long start=myid * nelems_per_thread; /* Start element index */
 	long end = start + nelems_per_thread;	/* End element index */
 	long i;

 	for (i = start; i < end; i++) {
		P(&mutex);
    gsum += i ;		
		V(&mutex);
 	}
  return NULL;
}
```

![image-20190623222742477](Chp12ConcurrentProgramming.assets/image-20190623222742477.png)

- 单线程比多线程慢
- 多核比单核慢
  - PV同步操作在多核上开销很大

#### V2:

在例程中持有私有变量, 在例程中不需要互斥锁维护更新

```c
/* Thread routine for psum-array.c*/
void *sum_array(void *vargp)
{
 	int myid = *((int *)vargp); 		/* Extract the thread ID */
 	long start=myid * nelems_per_thread; /* Start element index */
 	long end = start + nelems_per_thread;	/* End element index */
 	long i;

 	for (i = start; i < end; i++) {
		psum[myid] += i;
 	}
  return NULL;
}
```

![image-20190623223637466](Chp12ConcurrentProgramming.assets/image-20190623223637466.png)

#### V3:

减少内存引用

```c
/* Thread routine for psum-array.c*/
void *sum_array(void *vargp)
{
 	int myid = *((int *)vargp); 		/* Extract the thread ID */
 	long start=myid * nelems_per_thread; /* Start element index */
 	long end = start + nelems_per_thread;	/* End element index */
 	long i, sum = 0;

 	for (i = start; i < end; i++) {
		sum += i;
 	}
  psum[myid] = sum;
  return NULL;
}
```

![image-20190623223834420](Chp12ConcurrentProgramming.assets/image-20190623223834420.png)

### Characterizing the Performance of Parallel Program

![image-20190623232023975](Chp12ConcurrentProgramming.assets/image-20190623232023975.png)

并行程序在每个核心上运行一个线程

- Speedup加速比: S~p~ = T~1~ / T~p~

  - p: 处理器核心数
  - T~p~: 在p个核心上运行的时间
  - Strong Scaling: 强扩展
  - T~1~是顺序执行时间时, S~p~为绝对加速比
  - T~1~是并行版在单核的运行时间时, S~p~为相对加速比
    - 绝对加速比更优秀但是难以测量(需要单独的代码版本)

- Efficiency效率: E~p~ = S~p~ / p = T~1~ / pT~p~

  - Efficiency可以衡量由于并行化造成的开销

  - 高效率说明实际工作时间更多, 同步和通信时间少

    ![image-20190623234036593](Chp12ConcurrentProgramming.assets/image-20190623234036593.png)

  - 效率超过90%可遇不可求, 因为具体的任务通常很难并行化

- Weak Scaling弱扩展: 增加核心数的同事增加问题规模, 让每个核心工作量不变

## 7. Other Concurrency Issues

任何并发流操作共享资源会出现的问题

### 7.1 Thread Safety

Thead-safe iff 多线程并发调用函数总产生正确的结果(同串行一样)

共有四类线程不安全的函数类型

#### Class 1: _Functions that do not protect shared variables_

- 对未受保护(没有互斥锁)的共享变量进行读写是不安全的. 
- 要使用PV操作来保护共享变量
- 不需要对调用过程的任何修改
- 但是同步处理会减慢程序的执行时间

#### Class 2: _Functions that keep state across multiple invocations_

  e.g. 伪随机数生成

```c
unsigned int next = 1;
/* rand – return pseudo-random int on 0..32767 */
int rand(void) 
{
    next = next * 110351524 + 12345 ;
    return (unsigned int)((next/65536) % 32768);
}
/* srand – set seed for rand() */
void srand(unsigned int seed)
{
    next = seed;
}
```

- 每一次调用依赖于上一次调用的结果.
- 单线程多次调用可以预期一个可重复的随机数序列
- 多线层并发调用, 则序列不定
- 只能改写修订
  - 不再使用静态数据
  - 依靠caller在参数中传递状态信息

#### Class 3: _Functions that return a pointer to a static variable_

例如ctime和gethostbyname. 

- 经计算结果存放在一个静态变量中并返回指向变量的指针.
- 在多线程并发的时候会导致线程间的结果互相覆盖

修正

- 重写函数为: caller传递存放结果的地址

- 利用lock-and-copy, 将不安全函数的调用与互斥锁配合使用

- 例如ctime的包装版本

  ```c
  char *ctime_ts( const time_t timep, char *privatep) 
  {
      char *sharedp;
  
      P(&mutex);
      sharedp = ctime(timep);
      strcpy(private, sharedp) ;
      V(&mutex);
      return privatep;
  }
  ```

#### Class 4: _Functions that call thread-unsafe funtions_

f call g:

- g如果是第二类: f一定是不安全的
- g如果是第一类或者是第三类: f利用互斥锁封装g, 则f是安全的

### 7.2 Reentry

- Reentry的函数在被多个线程调用时不会引起任何共享数据

  ![image-20190624092854917](Chp12ConcurrentProgramming.assets/image-20190624092854917.png)

- Reentry函数更高效, 不需要同步操作

- 将第二类不安全函数转化为安全的唯一方式就是重写之为reentry的

  rand函数的reentry版本

  ```c
  int rand_r(unsigned int *nextp)
  {
    *nextp = *nextp * 1314245134 + 23415;
    return (unsigned int)(*nextp / 31515)%45151
  }
  ```

- 函数参数是pass by value的, 且数据引用都是栈上的, 那么函数是显式reentry的. 如何调用都是reentry的

- 如果是pass  by reference, 则函数式隐式reentry的, 调用时要传入非共享指针

- reentry是caller和callee双方的属性

### 7.3 Using Existing Library Functions in Thread Programs

- 所有standard c lib中的函数都是thread-safe的
- 大多数Unix的syscall是thread-safe的

![image-20190624100501287](Chp12ConcurrentProgramming.assets/image-20190624100501287.png)

- 第三类的修正可以用互斥锁, lock-and-copy
  - 降低速度
  - 深拷贝

### 7.4 Races

- 竞争: 程序的正确执行依赖于 其中一个线程到达x时, 另一个线程还未达到y点 

- 竞争的发生是因为programmer假定了状态空间中特定的轨迹线

- e.g.

  ```c
  #define N 4
  int main()
  {
      pthread_t tid[N];
      int i ;
      for ( i=0 ; i<N ; i++ )
         pthread_create(&tid[i], NULL, thread, &i);
      for ( i=0 ; i<N ; i++ )
         pthread_joint(tid[i], NULL) ;
      exit(0) ;
  } 
  /*thread routine */
  void *thread(void *vargp)
  {
      int myid = *((int *)vargp) ;
      printf(“Hello from th. %d\n”, myid);
      return NULL ;
  }
  ```

  output
  
  ```bash
  linux> ./race
  Hello from thread 1
  Hello from thread 3
  Hello from thread 2
  Hello from thread 3
  ```
  
  - 对等线程和主线程之间产生了竞争
    - line7创建线程时, 传递了栈上的变量i的指针
    - line15复制语句和line6的i++语句存在竞争
      - 复制必须在下一次循环开始前完成, 来得到正确的myid
      - 执行顺序依赖于系统调度
  - 消除竞争, 动态为传入参数分配内存, 由线程释放
  
  ```c
  int main()
  {
      pthread_t tid[N];
      int i, *ptr ;
      for ( i=0 ; i<N ; i++ ) {
         ptr = malloc(sizeof)int));
         *ptr = i ;
  		 	 pthread_create(&tid[i], NULL, thread, ptr);
      }
      for ( i=0 ; i<N ; i++ )
         pthread_joint(tid[i], NULL) ;
      exit(0) ;
  } 
  ```

### 7.5 Deadlock

- 死锁: 某一组线程被阻塞了, 并且在等待一个永远也不为真的条件

  ![image-20190624105740171](Chp12ConcurrentProgramming.assets/image-20190624105740171.png)
  - PV操作的顺序不对, 导致禁止区有重叠
    - 在每个线程都在等待其他其他线程执行一个不可能的V操作
  - 轨迹线进入死锁区就无法离开
  - 死锁的发生依赖于调度过程(特等的轨迹线)

- 二元互斥Semaphores

  - 互斥锁加锁顺序规则: 

    每个线程P操作不同的Semaphore时, V操作的Semaphore必须与P操作相反

    P(a), P(b)  <=> V(b), V(a)

- e.g.

  初始时 s = 1; t = 0.

  Thread1: P(s) V(s) P(t) V(t)

  Thread2: P(s) V(s) P(t) V(t)

  ![image-20190624111546004](Chp12ConcurrentProgramming.assets/image-20190624111546004.png)

  某个Semaphore初始为0时, 则其禁止区是进程禁止区的并集