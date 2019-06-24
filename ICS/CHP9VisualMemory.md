# CHP9 Visual Memory

系统中的进程共享CPU和Memory

现代OS为了管理进程间的内存使用, 提供对主存的抽象 — VM虚拟内存

- VM是硬件异常, 硬件地址翻译, 主存, 磁盘文件, 内核软件交互完成的
- VM为每个进程提供大的, 一致的, 私有的地址空间
- VM三个重要功能
  - 作为磁盘内容在地址空间的高速缓存, 只保留活动区域, 根据需要IO
  - 为每个进程提供一致的地址空间, 简化内存管理
  - 保护每个进程的地址空间不被其他进程破坏
- VM是系统操作的核心抽象
- VM给予进程强大的能力, 包括创建和销毁chunk, 将chunk映射到磁盘文件, 与其他进程共享文件
- VM暴露一些接口进行交互, 使用不当就会发生内存相关的错误(段错误)

## 1. Physical and Virtual Addressing

- 主存被组织成为一个由M个连续的Byte大小的单元组成

  - 每个Byte都有唯一的物理地址(PA)
  - 第一个Byte的地址为0, 紧接着1, 2, 3…

- CPU可以通过物理地址访问主存, 即物理寻址Physical Addressing

  - 当一条load指令发生时, CPU会生成一个有效的物理地址, 访问主存
  - 主存读取特定位置, 特定长度, 通过MemoryBus传回给CPU的一个reg

  ![image-20190624171802545](Chp9VisualMemory.assets/image-20190624171802545.png)

  - 早起的计算机仍使用物理寻址

- 虚拟寻址 Virtual Addressing

  ![image-20190624172124088](Chp9VisualMemory.assets/image-20190624172124088.png)

  - CPU通过生成一个虚拟地址访问主存
  - 在VM送达到内存之前, 先被转换为适当的物理地址 (地址翻译 address translation)
  - address translation需要CPU硬件和OS之间紧密合作
  - CPU上具有专用硬件 Memory Management Unit, MMU利用主存中的Lookup table开动态翻译虚拟地址到物理地址
  - Lookup table的内容是由OS管理的

## 2. Address Spaces



## 9 Dynamic Memory Allocator

> 分配程序运行中需要的额外内存
>
> Allocator 维护内存中的特定区域，heap，heap紧接着.bss区域，向高地址生长
>
> 对于每个进程，内核维护变量brk指向堆顶
>
> Allocator 将堆视为不同大小的块（BLOCK）集合来维护
>
> - > Block: 连续的内存片（chunk），拥有已分配和空闲两个状态
>   >
>   > ​	已分配：显示地保留，提供给应用程序使用
>   >
>   > ​	空闲：    用来被分配福
>   >
>   > ​	状态通过释放和分配转换
>   >
>   > ​	释放可以由应用程序显式执行，也可Allocator隐式执行
>
> - > 分配的基本风格：
>   >
>   > 显式的分配块（程序调用），区别释放方式
>   >
>   > - 显式Allocator: 要求应用程序自行显式地释放已分配的块
>   >
>   >   比如C代码程序中的`malloc`程序包显式分配block，`free`函数释放一个block；C++中对应new和delete操作符
>   >
>   > - 隐式Allocator: Allocator内部检查已分配的block是否可以被释放，也叫`garbage collector`， Lisp，ML，Java等高级语言通过垃圾收集释放内存

- ### `malloc`  and  `free` 

  > ```c
  > #include <stdlib.h>
  > void *malloc(size_t size);
  > ```

  malloc返回一个类型不定的指针，指向大小至少为size bytes的内存block，这个块中的任何数据对象可能会做类型对齐，32位返回为8倍数地址，64位返回16倍数地址

  malloc遇到问题，如size过大，就返回NULL，并设置errno；成功返回时不会初始化返回的内存，`calloc`可以返回清空的内存，`realloc`可以改变一个已分配的block的大大小

  Allocator（包括malloc）使用mmap，munmap来显示分配和释放内存

  `sbrk()`函数：

  > ```c
  > #include <unistd.h> //unix内核暴露给C的库
  > void *sbrk(intptr_t incr);
  > ```

  sbrk函数由系统提供，通过移动堆指针brk incr大小来实现对堆的扩展和收缩；成功则返回old brk，否则返回-1，将erron设置为ENOMEM；通过调用`sbrk(0)`得到当前堆指针的值；incr < 0 则可以缩减堆

  > ```c
  > #include <stdlib.h>
  > void free(void *ptr);
  > ```

  `free()`函数释放已分配的block

  参数ptr必须是由Allocator分配返回的块指针(分配块的起始位置)，否则free将发生危险的未定义行为，并且没有返回值

  - Why Dynamic Allocate

    应用程序运行中才会得到某些数据结构大小 

- ### Allocator的要求和目标

  Allocator工作的约束

  > - 处理任意请求序列
  >
  >   应用可以有任意的M&F请求序列，Allocator不可假设请求序列
  >
  > - 立即响应请求
  >
  >   不允许执行请求时，出于性能优化地缓存或者乱序重排
  >
  > - 只使用heap
  >
  >   出于扩展性
  >
  > - block的对齐要求
  >
  >   出于数据类型兼容
  >
  > - 不修改已分配的block
  >
  >   不允许修改和移动已分配block，不允许压缩分配

  Allocator的工作目标：最大化吞吐率（时间效率）和最大化内存使用率（空间效率）

  时间效率和空间效率是相互制约的

  > - 最大化吞吐率：
  >
  >   吞吐率定义为单位时间完成的请求数量，可以减小单个请求的平均执行时间；规定合理性能为分配请求是O(n)的（n是空闲block数量），释放的时间是O(1)的
  >
  > - 最大化内存利用率:
  >
  >   对于一串请求序列，如果一个应用程序请求p字节的块，那么已分配块的有效荷载payload为p，在请求序列执行完后，聚集有效荷载（aggregate payload）为Pk，是当前分配块的payload之和，Hk表示当前堆的大小（单调不减）
  >
  >   Peak utilization 堆的前k个请求的峰值利用率定义为:
  >   $$
  >   U_k=\frac{max_{i≤k}\{P_i\}}{H_k}
  >   $$
  >   内存利用率目标使得U_{n-1}最大化

- ### Fragmentation

  堆中存在free的块但是不能用来被没满足分配时导致碎片化，碎片化降低堆的利用率；碎片分为内部碎片和外部碎片

  - 内部碎片是分配的块的大小和他们payload之间的间隙

    内部碎片的数量只取决于以前请求的模式和Allocator的实现方式

  - 外部碎片是当空闲内存合计可以满足分配需求，但没有单独的块可以满足需求，需要生长heap来满足时，堆中分散的剩余空闲内存

    外部碎片还取决于未来的请求模式，难以量化，不可预测，Allocator常采用启发式策略维持小数量大体积的内存空间，而非反之

- ### Realization

  Problems

  > 空闲block组织：如何记录
  >
  > 放置：如何选择合适的空闲位置分配
  >
  > 分割：将新分配的block放置后，如何处理剩余的部分
  >
  > 合并：如何处理刚刚被释放的block

  - Implicit Free List

    ![屏幕快照 2018-12-28 23.19.02](./CHP9VisualMemory.assets/屏幕快照 2018-12-28 23.19.02.png)

    - Allocator需要数据结构取定边界和状态，这些信息嵌入block本身

    > ```c
    > /* 记录Block */
    > ```

    - Block结构

      - 头部header meta-data：

        **存放块大小的4bytes(单字)空间**；约束块双字（8b）对齐后，header后三位都为0；最低位复写0/1表示是否已分配

      - 有效荷载payload

        应用程序使用

      - 填充padding

        分配策略，对抗外部碎片，满足对齐

    - 堆结构：连续的（已分配/空闲）块组成的链式序列，称为隐式空闲链表

      空闲信息蕴含在header内部，Allocator需要通过遍历heap中所有的block从而遍历free block

      特殊标记的链表结束块为一个标记大小为0的已分配的header

      系统对齐要求和Allocator的格式对最小Block大小有要求

    > ```c
    > /* 放置已分配的block */
    > ```

    搜索到一个足够大的空闲block分配，放置策略有：

    - FF (First Fit) 首次适配：

      从头开始搜索链表，选择第一个可放入的freeBlock分配

      大块空心空间留在尾部，头部碎片化严重，增加了大块搜索时间

    - NF (Next Fit) 下次适配：

      从上次查询结束处做FF

      利用率不如FF

    - BF (Best Fit)  最佳适配：

      检查每个freeBlock，选择大小最接近的分配

      需要对堆进行完全搜索

    > ```c
    > /* 分割freeBlock */
    > ```

    当分配器找到freeBlock后分配的方式

    选用整个空闲空间会趋于内部碎片化

    匹配相差太大时采用分割，分配的部分独立，剩下的部分作为新的空闲块

    > ```c
    > /* 获取额外的heap */
    > ```

    在链表尾部物理相邻的内存创建新的空闲block加入链表，若heap不够扩展，则调用sbrk向系统申请；Allocator将新内存视为大的freeBlock加入链表

    > ```c
    > /* 合并freeBlock */
    > ```

    分配一个块后可能与其他空闲块相邻，多个空闲块相邻称为假碎片，需要进行合并（coalescing）；Allocator可以立即合并/推迟合并

    - 立即合并：

      每次释放后都会合并

      可能会产生合并后立即分割的抖动

    - 推迟合并：

      一段时间后合并所有的相邻空闲块

    > ``` c
    > /* 边界标记的Block 以及合并 */
    > ```

    释放当前块后，检查当前块的头部指针指向的下一个块时候空闲，若是则将其大小加入到当前块上，在O(1)时间内完成

    合并之前的空闲块需要全链表搜索并记住前面的块的位置，时间是O(n)的

    ![屏幕快照 2018-12-29 01.34.25](./CHP9VisualMemory.assets/屏幕快照 2018-12-29 01.34.25.png)

    Boundary tag技术思想类似于双向链表，允许在O(1)的时间向前合并

    在每个block结尾处添加一个footer，Allocator检查footer，判断前一个block的大小和状态，footer距离下一个block的header相邻

    释放的所有情况：

    - 前后都是已分配的：

      当前块变为空闲，无法合并

    - 前块是已分配的，后块空闲

      用当前和后块的大小和来更新当前的header和后块的footer

    - 前块空闲，后块是已分配的 

      用前块和当前的大小和来更新前块的header和当前的footer

    - 前后都是空闲的

      用三者之和的大小更新前块的header和后块的footer

    ![image-20181229101934671.png](./CHP9VisualMemory.assets/image-20181229101934671.png)

    当应用请求许多小块时，每个块的header和footer造成显著的空间开销

    分配时footer是可以复写的，将前者是否空闲的状态放入当前块中

    空闲块的footer必须持有大小信息，是必要的