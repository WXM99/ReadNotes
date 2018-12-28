# CHP9 Visual Memory



## 〇Dynamic Memory Allocator

> 分配程序运行中需要的额外内存
>
> DALL 维护内存中的特定区域，heap，heap紧接着.bss区域，向高地址生长
>
> 对于每个进程，内核维护变量brk指向堆顶
>
> DALL 将堆视为不同大小的块（BLOCK）集合来维护
>
> - > Block: 连续的内存片（chunk），拥有已分配和空闲两个状态
>   >
>   > ​	已分配：显示地保留，提供给应用程序使用
>   >
>   > ​	空闲：    用来被分配福
>   >
>   > ​	状态通过释放和分配转换
>   >
>   > ​	释放可以由应用程序显式执行，也可DALL隐式执行
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
