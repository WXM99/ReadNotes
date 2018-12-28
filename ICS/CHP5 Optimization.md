# CHP5 Optimization

> - Algorithm
> - Data Structure
> - Source code fitring compiler
> - Parallel

- Balence: Simplicity and Performance

- Fitting compiler to optimize

- Optimizing in **Target Machine Model**. 

  -  How: 如何处理指令
  -  Seq: 指令顺序以及组合
  -  Deseq: 乱序以及并行

  > - Parallel: 利用CPU硬件，降低DataDependency, 增加并行度
  > - Profiler: 模块化测定程序性能



## 〇 Boundedness of Compiler 

```shell
$gcc -og test.c
$gcc -o1 test.c
$gcc -o2 test.c
$gcc -03 test.c
```

- Compiler won't

  > 改变优化前的程序行为
  >
  > - 函数输入边界
  > - 指针指向相同内存
  > - 函数调用简化

- Optimization

  > - 内联函数替代函数调用 （-finline）



## 〇 Performance

- *Def:* **CPE**

  > Cycles Per Element 刻画迭代程序的循环性能
  >
  > - Cycles: 处理器活动的一个周期
  >   - 单位GHz: 千兆赫兹，10亿周期每秒

- Optimization: **循环展开，降低CPE**



## 〇 Optimization in Code



## 〇 Optimization in Machine

- 现代处理器结构

  ![modernCPU](/Users/Miao/Desktop/modernCPU.png)

  > - Feature:
  >   Superscalar & Out-of-order
  > - Structure:
  >   Instruction Control Unit (**ICU**) + Execution Unit (**EU**)
  > - ICU: 内存取指，分解指令
  > - EU: 乱序并行执行操作

  - ICU ：

    1. 从CPU中的InsCache取指，Decode指令，拆分为MicroInst发送到EU执行
    2. 取指控制：预测分支和分支目标地址并Decode, 纠正错误分支
    3. 指令译码：接受程序指令并转换为MicroOp，来进入不停地硬件单元，提高并行度

  - EU：在一个Cycle内读取多个操作，并指派到功能单元中

    1. LoadUnit, StoreUnit:

       加载单元处理从内存读值到寄存器的指令，包含一个加法器计算地址；储存单元处理写数据到内存的指令，保安一个加法器计算地址；LU和SU通过DataCache

    2. EU的投机反馈：

       验证正确后，将执行结果写回储存设备；验证错误后，丢弃处理结果，反馈正确分支地址到ICU，但是会带来性能处罚

    3. 功能单元 

       > 0. 整数运算、浮点乘法、整数和浮点除法，分支
       > 1. 整数运算、浮点加法、整数和浮点乘法
       > 2. Load、地址计算
       > 3. Load、地址计算
       > 4. Store
       > 5. 整数运算
       > 6. 整数运算、分支
       > 7. Store、地址计算
       >
       > （整数运算为基本位操作）

       功能单元的分布会对程序的并行度带来影响

    4. Retirement Unit

       记录正在进行的处理，确保汇编顺序

       - RegFile

         整数寄存器，浮点寄存器，AVX寄存器，SSE寄存器的更新都受退役单元的控制

       - 译码时，指令信息进入队列，并一直保持在队列中，直到指令正确完成（retire），所有寄存器可以被更新；或者被证明为错误指令，得以被清空，包括指令结果

       - CPU寄存器的更新当且仅当指令退役，为了尽早确认指令的正确新，执行单元之间的信息交流（forwarding）被汇集在操作结果总线上
       - 操作数在不同执行单元之间传送的版本控制机制为寄存器重命名（renaming）；设指令将更新寄存器r，该执行译码时，缠身标记t，得到该指令的唯一标记（r, t），加入表中，维护寄存器r和更新该寄存器的指令的时序t的关系；发送到EU的指令也会包含t作为源操作数的一部分，EU的某个单元完成操作后，生成结果（v, t）流入操作结果总线，则等待t作为源的指令可以直接调用v；renaming表中只包含没有写过的寄存器；当译码时表中没有目的寄存器时，直接在RegFile中取值；

  - 功能单元的性能

    - Latency：以一条指令为观察对象，记录其完成的总时间 （seq时间）

    - Issue Time：相邻同指令完成的时间间隔 （执行频率）

    - Capacity：执行运算的功能单元数量 （并行上限）

      整数

      |        | Latency | Issue | Capacity |
      | ------ | ------- | ----- | -------- |
      | add    | 1       | 1     | 4        |
      | mul    | 3       | 1     | 1        |
      | devide | 3~30    | 3~30  | 1        |

      浮点

      |        | Latency | Issue | Capacity |
      | ------ | ------- | ----- | -------- |
      | add    | 3       | 1     | 1        |
      | mul    | 5       | 1     | 2        |
      | devide | 3~15    | 3~15  | 1        |

      （issue = 1代表完全流水线化的操作，Latency = Issue的为强过程依赖操作）

    - Throughput：= 1/Issue （周期完成执行量，最大吞吐量）

      Throughput  * Issue = Capacity

    - CPE的两个基本界：

      - Latency Bound (延迟制约的CPE下界) （seq执行）
      - TP Bound (由吞吐量制约的CPE下界) （Capacity > 1）

  - 处理器操作的模型抽象 Data-Flow

    - 只记录循环中

    - 循环汇编

    - Decode拆分汇编指令为微指令（操作）

    - 操作从寄存器或者其他操作接收数据，并产生数据发送到其他操作或寄存器

    - 某些中间值（线值）没有出现在寄存器上，只在操作之间表示

      > 循环中寄存器的类别：
      >
      > - 只读：只作为源值（计算地址、cmp）
      > - 只写：只作为mov操作的汇
      > - 局部：在循环内部修改，使用，循环之间不相关(先写后读)
      > - 循环：既是源又是汇，一次迭代产生的值会在领一次用到

  - 循环展开

    代码级别的程序修改：增加每次循环计算元素的数量，减少迭代次数

    - 减少与程序结果无关的操作数量（ add i，index, cnd）
    - 减少CP上的操作数

    > 展开条件：
    >
    > - 第一次循环不会越界（len < 每层展开数）
    > - 处理尾相

    - 根据计算单元分配计算任务来提高并行性

  - 提高并行性

    > 前提：
    >
    > - 执行单元流水线化 => Issue = 1
    > - 多个储存单元 => 并行；（结合循环展开）
    > - 并行 => 打破数据的顺序相关

    - 多个累计变量

      对于可交换和可结合的线性运算，利用多个累积量的数据不相关，计算单元PIPE处理，缩短CP

      CPE达到吞吐量极限的条件：

      1. 功能单元的流水线塞满
      2. 每层循环展开数`K >= C*L `（C个功能单元均被填满）
      3. 保持原功能地去依赖

    - 重结合变换

      - 结合非依赖数据之间的运算，得到中间变量
      - 中间变量再与累积量运算
      - 两次运算无依赖，利用Pipe达到伪并行，减小CPE

    - SSE指令提高并行度

      - 最新版本为AVE = AVX
      - AVX 寄存器为16个32字节（256位）寄存器，可以存放一组整数或者浮点数
      - AVX指令对某个AVX寄存器进行向量操作，进行8组数值或者四组数值的加法乘法

  - Limitations

    - 寄存器溢出

      > 并行度超过可用寄存器的数量，编译器将临时数据储存在栈中，增加时间开销

    - 分支预测错误处罚

      > 在错误的分支被证实后，处理器需要丢弃所有投机执行的结构，在
      >
      > 产生有用的结果之前重新填充流水线
      >
      > 条件传送指令没有处罚，编译器会尽量将条件分支改为条件传送
      >
      > 参考机(i7)的惩罚周期为19个Cycles

      - 可预测的分支：

        > 循环内部的结束判断分支被预测为Taken，无需人为处理

      - Fitting CMOVE:

        > 用条件操作计算，利用计算结果更新状态

  - 内存性能

    > i7有两个load单元，fully Piped，Latency = 4
    >
    > 一个store单元，fully Piped, 

    - load性能

      链表测试，反复读取同一寄存器作为地址，相互依赖的load作为关键路径

      CPE = L

    - store性能

      store操作将寄存器的值写回内存

      store不会影响任何寄存器 => store操作之间没有数据依赖

    - store/load 依赖

      循环中反复写再读相同一块内存，导致S/L功能单元无法并行

      Store单元中存在一个待写入数据和地址缓存（48条），load指令读值是检查该缓存地址有无匹配，若有则存在依赖

      store操作被拆分成s_addr操作和s_data操作，并行执行

      ​	s_addr计算储存地址，并在store单元缓冲区存放带有改地址字段的条目

      ​	s_data在store缓冲区的该条目下补充数据字段

      1. s_addr必须略微超前s_data来创建条目
      2. load需要与StoreUnit中缓存的s_data比较确定是否存在读写依赖
      3. 存在依赖时，load要求s_data已经执行完成，得到最新数据，否则可以并行	
