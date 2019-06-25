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

- 地址空间Address Space: 非负整数地址集合 {0, 1, 2, ...} 
  - 整数连续 iff 线性地址空间
- 虚拟地址空间: CPU从一个有N = 2^n^个地址的地址空间中生成虚拟地址 {0, 1, 2, …, N-1}
  - 地址空间的大小由最大地址的位数描述
  - 现代系统支持32位或者64位的虚拟地址空间
- 物理地址空间: 对应于物理内存的M个Byte {0, 1, 2, … M-1}
  - M不要求是2的幂
  - 简化假设为M = 2^m^
- 地址空间区分了数据对象和其属性
  - 数据对象是对应的Byte的值
  - 属性是其地址编号
- 数据对象的属性推广: 
  - 每个数据对象有多个独立的地址
  - 每个地址都选自一个不同的地址空间
- 主存中的每个字节都有一个
  - 来自虚拟地址空间的虚拟地址
  - 来自物理地址空间的物理地址
- 常用的内存单位
  - 2^10^ = 1K kilo
  - 2^20^ = 1M mega
  - 2^30^ = 1G giga
  - 2^40^ = 1T tera
  - 2^50^ = 1P peta
  - 2^60^ = 1E exa

## 3. VM as a Tool for Caching

- VM被组织为一个由存放在磁盘上的N个连续Byte大小的单元组成的数组

  - 每个Byte都有唯一的VMA作为数组索引
  - 磁盘(低级储存)上的数据被分割成blocks, 作为与主存的传输单元

- VM系统将VM分割, 称为Virtual Page. VP

  - VP大小固定, 用来适配磁盘的block
  - VP的大小P = 2^p^ Byte

- 物理内存被分割为屋里页PP, 大小也是P byte. 也叫做Page Frame

- 任意时刻, VP的集合可以划分为三个不想交子集

  1. Unallocated: 

     VM系统还没有分配或者创建的page. 没有数据与之关联, 不占用任何磁盘空间

  2. Cached:

     缓存的page. 对应的数据在物理内存中已分配了PP

  3. Uncached: 

     已经分配了但是物理内存中没有缓存的Pages

  ![image-20190624194818187](Chp9VisualMemory.assets/image-20190624194818187.png)

### 3.1 DRAM Cache Organization

- SRAM cache代表CPU和Memory之间的L1L2L3
- DRAM cache代表VM系统的缓存, 在主存中缓存VP
- DRAM cache miss后会访问磁盘, 开销巨大. 导致了DRAM cache的特殊结构
  - 巨大的VP: 4KB~2MB
  - fully-associativity: 全相连, 1set1line. 任何VP都可以放置在任何PP中
  - 更精密的淘汰算法
  - 总是writeBack(passive). 不直写

### 3.2 Page Tables

- VMsys必须判定一个VP是否缓存在DRAM中somewhere

  - 若存在, VMsys要知道这个VP存放在在哪个PP

  - MIss, VMsys要判断VM的磁盘位置, 在PP中选择一个牺牲, 将这个VP从磁盘复制到DRAM替换牺牲页

  - 这些功能由软硬件联合提供

    - OS

    - MMU的地址翻译硬件

    - 物理内存中Page table数据结构

      Page table将VP映射到PP. MMU进行VMA到PMA地址翻译时, 会读取页表

      OS负责维护页表, 以及在Disk和DRAM之间传送页

- Page Table: 一个Page Table Entry PTE的数组

  ![image-20190624202626306](Chp9VisualMemory.assets/image-20190624202626306.png)

  - 每个虚拟地址空间的VP都在Page Table中有一个固定位置的PTE
  - PTE由一个valid bit和n位地址两个字段组成
    - valid bit表明PTE对应VP是否缓存在DRAM中
    - 如果设置了valid bit那么地址字段表示了对应的PP在DRAM中的起始位置, PP缓存了VP
    - 如果没有设置valid bit
      - 一个空地址表示VP还没有分配
      - 非空地址为VP对应的磁盘起始位置

### 3.3 Page Hits

当CPU需要访问的VP是cached

- MMU将虚拟地址作为引索来定位对应的PTE
- MMU从内存中读取对应的PTE
- MMU使用PTE中的物理内存地址(指向PP起始位置)构造数据的物理地址

![image-20190624204228651](Chp9VisualMemory.assets/image-20190624204228651.png)

### 3.4 Page Faults

DRAM的cache miss称为page fault

当CPU需要访问的数据所在的VP是Uncached

- MMU从虚拟地址解析对应PTE索引
- 从valid bit判断VP是 uncached
- MMU触发一个page fault exception
- exception调用内核的page fault exception handler的程序
  - handler牺牲DRAM中的一个PP, 写回磁盘
  - 修改牺牲PP对应的PTE
  - 内核根据地质从磁盘复制对用内容到DRAM中的PP
  - 更新访问的对应的PTE
  - 内核返回
- 重新执行导致page fault的指令
- MMU按照page hit的方式读取数据

![image-20190624205628820](Chp9VisualMemory.assets/image-20190624205628820.png)

![image-20190624210917777](Chp9VisualMemory.assets/image-20190624210917777.png)

### 3.5 Allocating Pages

OS分配一个新的VP时, 更新对用PTE使其地址指向磁盘上的Page

![image-20190624211038353](Chp9VisualMemory.assets/image-20190624211038353.png)

### 3.6 Locality to Rescue Again

- Virtual memory works because of locality
- At any point in time, programs tend to access a set of active virtual pages called the **working set**.
- Programs with better temporal locality will have smaller working sets
- If (working set size < main memory size) 
  - Good performance for one process after compulsory misses
- If (working set sizes > main memory size ) 
  - Thrashing*:* Performance meltdown where pages are swapped (copied) in and out continuously

## 4. VM as a Tool for Memory Management

- OS会为每个进程提供一个独立的page table

  - 所以进程具有了独立的虚拟地址空间

  - 多个VP也可能映射到一个共享的PP上

    ![image-20190624212657572](Chp9VisualMemory.assets/image-20190624212657572.png)

  - 一个VP在不同时间也会映射到不同的PP上

    ![image-20190624212931550](Chp9VisualMemory.assets/image-20190624212931550.png)

- 简化链接: 

  - 独立的地址空间让每个进程的内存映像有相同的基本格式
  - 不用考虑代码和数据实际存放在物理地址的位置
  - 简化Linker的设计和竖线, 允许Linker生成exe. 并独立于物理内存中代码和数据的最终位置 

- 简化加载:

  - 将目标文件的.text和.data section加载到进程中
  - Loader为代码和数据分配VP, 并标记为Uncached
  - PTE指向目标文件的适当位置(磁盘上)
  - Loader不会从磁盘复制任何数据到内存, 只有当每个VP被首次引用时, VMsys才会按需自动page in
  - memory mapping: 将一组连续的VP映射到任意一个文件的任意位置

- 简化共享:

  - 独立地址空间为操作系统提供管理用户进程和自身之间共享数据的机制
  - 每个进程自己的私有代码, 数据, 堆栈不和其他共享
    - OS创建page table, 将对应的VP映射到不连续的PP
  - 进程之间共享数据和代码借助于OS内核代码
    - 将不同进程中引用库程序的代码VP映射到同一个PP, 使得对个进程共享一个代码副本

- 简化内存分配:

  - 进程请求额外的堆空间时
  - OS分噢诶若干个连续VP并映射到物理内存中任意位置的相同数量的PP, 不是连续的

## 5. VM as Tool for Memory Protection

为操作系统提供手段来控制对内存的访问

- 进程不可修改只读代码段
- 进程不得读取和修改内核代码和数据结构
- 进程不能读写其他进程的私有内存
- 进程不允许修改与其他进程共享的VP
  - 进程间通讯的系统调用除外

对PTE添加额外的许可位来控制VP的访问权限

![image-20190624222618969](Chp9VisualMemory.assets/image-20190624222618969.png)

- 每个PTE中增加了三个许可位 permission bits
  - SUP: 进程是否必须运行内核模式下才能访问的PP
    - 内核模式可以访问所有PP, 用户模式只能访问SUP=0的PP
  - READ: 进程有读PP的权限
  - WRITE: 进程有写PP的权限
- 违反权限的指令触发一般保护故障(general protection fault)
  - 将控制传递给内核中的exception handler
  - Linux shell称为segmentation fault

## 6. Address Translation

基本参数

![image-20190624223857622](Chp9VisualMemory.assets/image-20190624223857622.png)

![image-20190624224732853](Chp9VisualMemory.assets/image-20190624224732853.png)

- 地址翻译: 
  - 一个在N个元素的虚拟地址空间VAS中的元素
  - 一个在M和元素的物理地址空间PAS中的元素
  - 上二者之间的映射

  MAP: VAS -> PAS ∪ ∅

  - MAP(A) = 
    - A’  iff 虚拟地址A出的数据在PAS的物理地址A’处
    - ∅  iff 虚拟地址A处的数据不在物理内存中

  ![image-20190624224559946](Chp9VisualMemory.assets/image-20190624224559946.png)

- MMU利用page实现这种映射

  ![image-20190624224452255](Chp9VisualMemory.assets/image-20190624224452255.png)

  - CPU中存在一个控制寄存器 Page Table Base Register PTBR, 总指向当前进程的Page Table (物理地址)
  - n位虚拟地址包含两部分
    - p bits: Virtual Page Offset. VPO
    - n-p bits: Virtual Page Number. VPN
  - MMU利用VPN作为索引来选择PTE
  - 将PTE中的Physical Page Number. PPN与虚拟地址的VPO相连接, 得到对应的物理地址
  - PP和VP的大小相同, 所以PPO = VPO

- Page hit的硬件执行

  ![image-20190624225752050](Chp9VisualMemory.assets/image-20190624225752050.png)

  1. CPU生成一个虚拟地址VA, 提交给MMU
  2. MMU通过VA的VPN和PTBR得到PTE地址PTEA, 从Cache/Memory请求之
  3. Cache/Memory返回PTE数据给MMU
  4. MMU通过PTE地址段和VA的VPO构造物理地址PA, 并向Cache/Memory请求数据
  5. Cache/Memory返回数据给CPU

  Page hit全是由硬件(MMU)处理的

- Page fault的处理过程

  ![image-20190624230457078](Chp9VisualMemory.assets/image-20190624230457078.png)

  Page fault的处理过程需要硬件和OS内核协作

  1. CPU生成一个虚拟地址VA, 提交给MMU
  2. MMU通过VA的VPN和PTBR得到PTE地址PTEA, 从Cache/Memory请求之
  3. Cache/Memory返回PTE数据给MMU
  4. MMU察觉PTE中的valid bit是0, 触发一次exception. 将控制从CPU中传递到OS的Page Fault Handler
  5. Handler决定物理内存中的Victim Page, 并执行Write Back (Paging out)
  6. Handler从磁盘上Page in新的页面到物理内存, 更新PTE
  7. Handler返回到原进程, 从新执行导致缺页的命令, 执行Page hit

### 6.1 Integrating Cache and VM

访问SRAM中的数据, 使用VA还是PA?

- 大多数系统使用PA
- 使用PA时, 多个进程可以共享SRAM Cache
- SRAM不需要处理保护问题: 权限在MMU进行地址翻译时检查

![image-20190624234831966](Chp9VisualMemory.assets/image-20190624234831966.png)

- 先做MMU的地址翻译, 再向L1做缓存查找
- MMU访问PTE也是可以被L1缓存的

### 6.2 Speeding Up Address Translation with a TLB

当CPU产生一个虚拟地址时, MMU就必须向内存中的Page Table请求查阅一个PTE来得到物理内存. 当L1 Miss时, 开销增长到几百周期

- MMU中包括了一个关于PTE的小缓存, Translation Lookaside Buffer. TLB

  - TLB是一个小容量, 虚拟地址寻址的缓存

  - 每一行保存一个有单个PTE组成的block

  - TLB具有高的associativity

  - TLB查找的组选择和行匹配索引是从VA得到的

    ![image-20190625000852119](Chp9VisualMemory.assets/image-20190625000852119.png)

    - 设TLB有 T = 2^t^ 个组
      - TLBI(index)由VPN的低t位构成
      - TLBT(tag)有VPN的剩余组成

- TLB Hit (所有步骤均在MMU高速进行)

  ![image-20190625001246367](Chp9VisualMemory.assets/image-20190625001246367.png)

  1. CPU产生一个虚拟地址VA
  2. MMU根据VA的VPN在TLB中查找
  3. TLB返回查找到的PTE
  4. MMU根据PTE获取物理地址PA, 向Cache/Memory请求数据
  5. Cache/Memory返回数据给CPU

- TLB Miss

  ![image-20190625001548082](Chp9VisualMemory.assets/image-20190625001548082.png)

  ...

  3. TLB中未找到对应PTE, MMU直接通过PTBR向内存/Cache请求PTE
  4. 内存/Cache返回PTE, TLB得到更新, MMU得到翻译PA

  ...

- 综合TLB和Cache

  ![image-20190625002421849](Chp9VisualMemory.assets/image-20190625002421849.png)

### 6.3 Multi-Level Page Tables

虚拟地址空间太大导致single page table太大(64位达到512G)

- 利用分级页表压缩

  ![image-20190625010812792](Chp9VisualMemory.assets/image-20190625010812792.png)

  - 一级页表: 每一个PTE对应VAS中连续的chunk的物理基地址
  - 二级页表: 对应一个chunk, 每个PTE对应一个VP

- 减少内存要求:

  - 如果一级页表中某个PTE是空的, 那么对应的二级页表不会再内存中存在
  - 只有一级页表是常驻内存的, 二级页表可以在需要时创建, 调入, 热度访问

- 多级规则

  ![image-20190625011946852](Chp9VisualMemory.assets/image-20190625011946852.png)

  - VA被划分为多个VPN, 每一个对应一级页表
  - 最低级页表PTE包含对应PPN或是磁盘地址
  - MMU必须多次访问PTE来获取PPN
  - PPO和VPO相同
  - 多级访问开销不大, TLB可以优化

## 7. The Intel Core i7/Linux Memory System

Pentium

- **32** **bit address space**

  -  **4 KB page size**

  -  **L1, L2, and TLBs**

    • **4-way set associative**

     **inst** **TLB**

  • **32 entries**

  • **8 sets**

   **data TLB**

  • **64 entries**

  • **16 sets**

   **L1** **i** **- cache and d-cache**

  • **16 KB**

  • **32 B line size**

  • **128 sets**

   **L2 cache**

  • **unified**

  • **128 KB -- 2 MB**

  • **32 B line size**

![image-20190625101722240](Chp9VisualMemory.assets/image-20190625101722240.png)

Intel Core i7

- Haswell
- 48-bit VAS
- 52-bit PAS
- Processor package
  - 4 cores
    - Hierarchy of TLBs
      - 4-way set associativity
    - Hierarchy of d-Caches
    - Hierarchy of i-Caches
    - QuickPath Interconnect
    - L2: 256KB, 8-way
  - one shared L3: 16-way
  - DDR3 memory controller

![image-20190625101921569](Chp9VisualMemory.assets/image-20190625101921569.png)

### 7.1 Core  i7 Address Translation

- 从CPU产生VA开始, 直到数据送回到CPU
- Core i7采用四级页表, 每个进程页表私有
- 允许页表paging in and out, 但是与allocated page相关的页表常驻内存
- CR3 controll register指向第一级页表的起始位置
- CR3是进程私有的, 属于进程context

![image-20190625102427716](Chp9VisualMemory.assets/image-20190625102427716.png)

#### PTE in Level1 2 3

![image-20190625103100308](Chp9VisualMemory.assets/image-20190625103100308.png)

- P: 下一级页表是否存在于DRAM中, 0位不存在
- R/W: 对于所有可访问的页(子表), 只读 或者 读写权限
- U/S: 对于所有可访问的页(子表), 用户或者 sup访问权限
- W/T: 下一级页表 writeback或者 writethrough缓存策略
- CD: 能不能缓存子页表
- A: 引用位(MMU在读写时设置, 软件擦除)
- PS: 页的大小
  - level1: 512G
  - level2: 1G
  - level3: 2MB
- G: global page (don’t evict from TLB on task switch)
- Base addr: 子页表的物理基地址(PPN 40-bit), 要求4KB对齐
- XD: 是否允许从PTE对应Page取出指令执行

#### PTE in Level4

![image-20190625104440002](Chp9VisualMemory.assets/image-20190625104440002.png)

- XD: 是否允许从PTE对应Page取出指令执行

- Base addr: 子页的物理基地址(PPN 40-bit), 要求4KB对齐

- G: global page (don’t evict from TLB on task switch)

- D: Dirty bit (Set by MMU on writes, cleared by software)

- A: 引用位(MMU在读写时设置, 软件擦除)

- CD: Cache disabled(1) or enabled(0) for child page table

- WT: Write-through or write-back cache policy
- U/S: User or supervisor(kernel) mode access permission
- R/W: Read-only or read-write access permissiom
- P: Child page table present in memory(1) or not(0)

64位系统还具有XD: 禁止执行, 用来禁止某些内存页代码的执行, 降低了buffer overflow的攻击风险

MMU翻译时更新handler会用的bit. A用来做替换算法, D确定是否写回. 内核也可以修改这些位

![image-20190625110240265](Chp9VisualMemory.assets/image-20190625110240265.png)

i7的MMU将VA划分为 9+9+9+9 + 12

- 每个9位的VPN是每一级页表的偏移量
- CR3拥有第一级页表的基地址(物理)
- 每一级页表PTE对应页的虚拟空间大小不同
  - VAS: 2^48^B
  - L1:  2^48^B / 2^9^PTE = 2^39^ B/PTE = 512GB/PTE
  - L2: 2^39^B / 2^9^PTE = 2^30^B/PTE = 1GB/PTE
  - L3: 2^30^PTE / 2^9^PTE = 2^21^B/PTE = 2MB/PTE
  - L4: 2^21^PTE/ 2^9^PTE = 2^12^B/PTE = 4KB/PTE

#### Speeding Up L1 Access
![image-20190625143627792](Chp9VisualMemory.assets/image-20190625143627792.png)

MMU在翻译PA的同时, 将VPO送达到 L1 Cache

- L1 Cache是8-way 64Byte-Cacheline, 64set, 
- 12位的VPO恰好可以同时在L1 Cache上查找到一个set的一组字(特定offset)
- MMU得到PPN后发送到L1 Cache, L1 Cache只需要把PPN作为CT与查找到的8个Tag比对

### 7.2 Linux Virtual Memory System

硬件与内核软件的紧密协作

- Linux为每个单独的进程维护一个VAS

  ![image-20190625143511909](Chp9VisualMemory.assets/image-20190625143511909.png)

  - Kernel Virtual Memory在用户栈上, 包含内核的代码和数据结构
  - 不同进程VAS中, KVM使用某些的VA将会被映射到所有进程共享的PP上
  - Linux将一组连续的VP映射到对应连续的PP上
    - 为内核提供访问任何物理位置的方法
  - 内核的其他区域是进程间不同的

#### Linux Virtual Memory Areas

VM是area(section)的集合

- 一个area是allocated的VP的连续片 — chunk

  - chunk的VP之间关联: .data .text heap shared-lib stack
  - 每个VP都在一个Area中
  - Area使得VAS之间有间隙, 而内核不用记录间隙, 间隙没有资源开销

- KVM的内核数据结构

  ![image-20190625163643678](Chp9VisualMemory.assets/image-20190625163643678.png)

  - 内核为每个进程维护一个单独的task_struct entry

    - tusk_struct包含内核运行该进程的所有信息 (PID, %rsp, PC…)

  - task_struct的一个entry指向mm_struct

    - mm_struct描述了VM的当前状态

    - pgd字段: 指向第一级页表的基地址(PA)

      内核运行该进程时, 将pgd放入CR3

    - mmap字段: 指向vm_area_structs的链表

    - vm_area_structs描述了当前VAS的一个area

      - vm_start: area的开始处
      - vm_end: area的结束处
      - vm_prot: area内部所有VP的读写权限
      - vm_flags: area内部的VP是与其他进程共享的还是私有的
      - vm_next: 指向下一个vm_area_structs

#### Linux Page Fault Exception Handler

![image-20190625165920897](Chp9VisualMemory.assets/image-20190625165920897.png)

MMU在翻译时, 察觉到从TLB或者Cache/Memory得到PTE中valid bit是0. 触发一个Page Fault Exception, 控制转移到内核的handler, 开始

1. 判断虚拟地址A是否合法: 

   A是否在Area内部 -- 搜索vm_area_structs链表, 一一比对. 如果A是间隙地址, 则抛出一个segmentation fault, 终止进程

2. 判断内存访问是否合法

   进程是否有读写执行这个area的权限, 权限不足则触发Protection Exception

3. Paging In

   对VA的操作是合法的, 但是VP是Uncached. handler选择牺牲一个page out. Paging in新的VP, 更新page table. handler返回后重启指令 

## 8. Memory Mapping

- Memory Mapping: Linux通过关联VM-Area和磁盘上的obj来初始化VM-Area的内容. obj可以是

  - Linux文件系统中的普通文件: 

    一个Area可以映射到一个普通磁盘文件的连续部分. 例如Executable obj file.

    - section被分成页大小的片, 每一片对应一个VP的初始内容
    - 这些对应的VP按需调度, 没有实际进入物理内存
    - CPU第一次引用VP时(读取一个VA在VP上)才会paging in
    - 如果文件小于Area, 剩余部分用0填充

  - Anonymous file:

    一个Area可以映射到一个匿名文件. 

    - 匿名文件由内核创建, 包含全是二进制的0
    - CPU第一次引用匿名页面时, 内核在物理内存中找到一个牺牲页
    - 用二进制的0覆盖PP, 同时更新Page Table, 标记为Cached
    - 这些匿名文件对应的PP也叫demand-zero page

- 一旦VP被初始化了, 就会在内核维护的swap file和内存之间被交换

  swap file也叫swap space或者swap area, 限制进程能分配的VP总数

- Demand Paging

  - 所有初始化的VP只有在被引用的时候才会被物理内存Paging in

### 8.1 Shared Objects Revisited

将VMsys和传统文件系统相集成, name把程序和数据文件Load到内存中会更高效和方便

- 进程的抽象让VAS相互独立, 保护进程安全

- 不同的进程有相同的rodata(只读代码区域), 例如库代码

- Memory Mapping提供进程共享对象的机制

  - 一个对象被映射到VM中的一个area, 要么是共享的, 要么是私有的
  - 进程映射一个共享对象到VM-Area, 对其的更改对其他映射过得进程可见, 也会修改磁盘上的原始对象
  - 进程对私有对象在的区域做改变, 其他进程不可见, 且不会反映到磁盘对象上
  - 映射共享对象的Area为共享Area, 反之为私有Area

  ![image-20190625212403432](Chp9VisualMemory.assets/image-20190625212403432.png)

  - 进程1讲一个共享对象到其VM的一个Area中 

    ![image-20190625212500919](Chp9VisualMemory.assets/image-20190625212500919.png)

  - 进程2对相同的对象做映射(VA可以不同)

  - 每个对象文件名唯一, 内核可以使进程2的PTE直接指向对应PP

  - 共享对象被映射到了多个VAS的area中, 但在物理内存中只有一个副本

  - 该对象在物理内存中的PP也不一定是连续的

  - 但是VP和磁盘内容是连续的

- 私用对象运用Copy-on-write COW技术映射到VM中

  - 当一个进程映射了, 另一个进程也映射了, 则他们对应同一个物理内存副本
  - 私有对象进程对私有区域的PTE是只读的
  - 私有Area的vm_area_structs的flag是 private COW的
  - 没有进程改写私有area时, 所有进程共享物理内存的单一副本
  - 某一个进程改写私有Area的VP时, 写操作触发protection fault
    - handler检测到fault由进程写私有Area的VP引起的
    - handler在物理内存中为VP在物理内存创建一个新的PP副本
    - 更新进程的PTE指向新的PP副本, 恢复可写权限
    - CPU重新执行写操作

  ![image-20190625213906836](Chp9VisualMemory.assets/image-20190625213906836.png)

### 8.2 The `fork` Function Revisited

fork创建带有独立VM的新进程

- fork被父进程调用,  内核会为子进程创建相关数据结构, PID
- 创建属于子进程的VAS, 创建父进程的mm_struct,vm_area_struct,
  and page tables的原样副本
- 将父子进程的每个VP标记为只读, 每个area标记COW
- fork返回后, 子进程的VAS和父进程一致且有相同的PP副本
- 两个进程之后的任何写操作都会导致COW创建新的PP, 因此每个进程VAS独立

### 8.3 The `execve` Function Revisited

execve在当前进程加载指向一个可执行的目标文件, 替代当前进程

- 删除原进程VM中的用户Area

- 映射私有Area: 为新程序的代码, 数据, bss, 栈区域创建新的vm_area_struct. 并且都标记为私有COW, 创建新的Page Table

  - 代码段: .text
  - 数据段: .data
  - bss: demand-zero, 映射匿名文件
  - 堆和栈也是demand-zero, 但是初始长度是0

  ![image-20190625215922366](Chp9VisualMemory.assets/image-20190625215922366.png)

- 映射共享area: 将一些共享库映射到进程VM的共享Area

- 设置PC: 将PC设置为新进程的程序入口(.text入口)

### 8.4 User-Level Memory Mapping with the `mmap` Function

mmap是一个syscall, 要求内核在当前进程的VAS中创建新的Areas, 用来连续地映射文件 

```c
#include <unistd.h>
#include <sys/mman.h>
void *mmap(void *start, 
           int len, 
           int prot, 
           int flags, 
           int fd, 
           int offset);
```

成功返回指向映射区域的通用指针, 出错为MAP_FAILED(-1)

![image-20190625222230248](Chp9VisualMemory.assets/image-20190625222230248.png)

- 映射的地址最好从start开始

- 被映射的的文件是fd指定的对象的连续的chunk

- 连续对象大小事len Byte

- 距离文件头的偏移量是offset

- start的地址不是强制的, 通常是NULL

- prot是映射到的VAS中Area的访问权限(vm_area_structs的vm_prot bits)

  - PROT_EXEC: 区域内的page由可以被CPU执行的指令组成
  - PROT_READ: 区域内的页面可读
  - PROT_WRITE: 区域内的页面可写
  - PROT_NONE: 区域内的页面不能被访问

- flags描述被映射对象类型的位组成

  - MAP_ANON: 被映射的是匿名对象, 对应的VP是0
  - MAP_PRIVATE: 被映射的对象是私有COW的
  - MAP_SHARED: 被映射的是共享对象

  ```c
  bufp = Mmap(NULL, size, PROT_READ, MAP_PRIVATE|MAP_ANON, 0, 0);
  ```

- 利用`mmap`做fast file copy: 避免使用用户空间传输文件

  ```c
  /* 
   * mmapcopy - uses mmap to copy file fd to stdout
   */
  void mmapcopy(int fd, int size)
  {
    char *bufp;
    /* map the file to a new VM area */
    bufp = mmap(NULL, size, PROT_READ, 
                MAP_PRIVATE, fd, 0);
    /* write the VM area to stdout */
    write(1, bufp, size);
    return ;
  }
  
  int main(int argc, char **argv) 
  {
    struct stat stat;
    /* check for required command line argument */
    if ( argc != 2 ) {
      printf(“usage: %s <filename>\n”, argv[0]);
      exit(0) ;
    }
    /* open the file and get its size*/
    fd = open(argv[1], O_RDONLY, 0);
    fstat(fd, &stat);
    mmapcopy(fd, stat.st_size);
  }
  ```

  快速在于只读的Area buf实际与打开的文件共享一份物理内存副本

- `munmap`函数删除VM中的area, 变为间隙

  ```c
  #include <unistd.h>
  #include <sys/mman.h>
  int munmap(void *start, size_t len);
  ```

## 9. Dynamic Memory Allocator

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