# Chp 8 Exceptions

## 5 Signal

> A kind of software exception
>
> A signal is a little message
>
> - From: SYSTEM
> - TO: APPLICATION
> - CONTENT: a kind event in sys
>
> 底层硬件异常由kernel处理, 一般用户不可见; signal可以通知用户这些异常的发生
>
> 高级的软件事件也可以发送信号

| 序号 | 名称      | 默认行为        | 事件                         |
| ---- | --------- | --------------- | ---------------------------- |
| 1    | SIGHUP    | 终止            | 终端线挂断                   |
| 2    | SIGINT    | 终止            | 键盘中断(Ctrl+c) 软件发出    |
| 3    | SIGQUIT   | 终止            | 键盘退出                     |
| 4    | SIGILL    | 终止            | 非法指令                     |
| 5    | SIGTRAP   | 终止 dump core  | 跟踪陷阱                     |
| 6    | SIGABRT   | 终止 dump core  | abort函数的终止信号          |
| 7    | SIGBUS    | 终止            | 总线错误                     |
| 8    | SIGFPE    | 终止 dump core  | 浮点异常                     |
| 9    | SIGKILL   | 终止            | 杀死进程信号 (软件发出)      |
| 10   | SIGUSR1   | 终止            | 用户定义的信号1              |
| 11   | SIGSEGV   | 终止 dump core  | 无效内存引用 (seq fault)     |
| 12   | SIGUSr2   | 终止            | 用户定义的信号2              |
| 13   | SIGPIPE   | 终止            | 写入没有读用户的pipe         |
| 14   | SIGALRM   | 终止            | 来自alarm函数的定时信号      |
| 15   | SIGTERM   | 终止            | 软件终止信号                 |
| 16   | SIGSTKFLT | 终止            | 协处理器的栈错误             |
| 17   | SIGCHLD   | 忽略            | 子进程的终止或者结束         |
| 18   | SIGCONT   | 忽略            | 继续停止的进程               |
| 19   | SIGSTOP   | 停止直到SIGCONT | 不是来自终端的终止信号       |
| 20   | SIGSTP    | 停止直到SIGCONT | 来自终端的终止信号           |
| 21   | SIGTTIN   | 停止直到SIGCONT | 后台向终端读                 |
| 22   | SIGTTOU   | 停止直到SIGCONT | 后台向终端写                 |
| 23   | SIGURG    | 忽略            | 套接字紧急情况               |
| 24   | SIGXCPU   | 终止            | CPU时间超出限制              |
| 25   | SIGXFSZ   | 终止            | 文件大小超出限制             |
| 26   | SIGVTALRM | 终止            | alarm满期                    |
| 27   | SIGPROF   | 终止            | 剖析定时器满期               |
| 28   | SIGWINCH  | 忽略            | 窗口大小变化                 |
| 29   | SIGIO     | 终止            | I/O possible on a descriptor |
| 30   | SIGPWR    | 终止            | 电源故障                     |

> core dump意为将内存内程序的数据和代码导出到磁盘上存储
>
> SIGSTOP不可被捕获和忽略

### 5.1 Terminology

- 传送一个signal到目的进程的步骤

  1. Sending a signal:

     Kernel通过更新目标进程的context的某个状态, 发送或者递交signal给子进程.

     发送的原因有:

     1. Kernel检测系统事件(/0, 子进程终止)
     2. 另一个进程调用了kill(send)函数来指定内核发送信号

  2. Receiving a signal:

     目标进程被kernel强迫对signal做出反应, 可以做出默认反应, 也可以通过signal handler的用户层函数捕获信号

     1. 进程接收到信号
     2. 进程传递到signal handler
     3. signal handler运行
     4. signal handler返回到下一条指令

     ![image-20190417164529993](Chp8Exceptions.assets/image-20190417164529993.png)

  3. Pending signal

     发出但是没有被接收的信号. 任意时刻, 一种类型至多只能有一个pending signal. 没有列队的机制, 重复的pending signal会被丢弃

  4. 进程可以选择性的block某种signal, 当某种signal被block后, 他仍可以被发送, 但不会被接收, 除非取消block

     一个pending signal至多只会被接收一次. Kernel为每个进程在pending bits vector中维护pending signal的集合, 在blocked bits vector中维护block signal集合. k类信号对应于vector的第k位