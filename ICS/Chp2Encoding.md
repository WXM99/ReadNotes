# CHP2 Encoding

bits + interpretation 可以任何有限几何元素

- 无符号数：范围小，精确，会溢出
- 有符号数：范围小，精确，会溢出
- 浮点数：范围大，不精确

## 2.1 信息储存

- 8bits = 1 byte, byte是内存中最小的寻址单位

- 内存全体地址集合为虚拟地址空间

- 2进制-10进制-16进制的转换

  - 4bit --> 1x

- 数据类型大小(Byte)

  - ​                                   32位     64位
    - unsigned/char     1           1
    - unsigned/short   2            2
    - unsigned/int        4            4
    - unsigned/long     4 *         8 *
    - int32_t/uint32_t   4            4
    - int64_t/uint63_t   8            8
    - char*(addr)          4 *         8 *
    - float                       4            4
    - double                   8            8

- 32位于64位区别在于虚拟地址空间的维度，32位最大空间为2^32 bits = 4GB; 64位最大空间为16EB

- 64位机可编译32位机器程序(向后兼容) 程序编译时指定

  ```shell
  $> gcc -m32 prog.c
  $> gcc -m64 prog.c
  ```

- char在自动被ascii解码时视为字符，实际储存的为一个整数(00000000-11111111)，为一个整数类型，C标准不保证其有无符号

- 读取内存中的数据时要考虑两个问题：

  1. 数据起始位置的内存地址是什么——用一个十六进制数表示（绝对地址）数据使用的字节中最小的地址
  2. 数据在内存中是如何排列的：
     - 大端法(big-endian)：
       最高有效位放入最小内存位置(内存从小到大排布的顺序同自然书写顺序)
     - 小端法(little-endian)：
       最低有效位放入最小内存位置(内存字节顺序与自然书写顺序相反)
     - e.g.  int a = 0x12 34 56 78; 
       a在小端法内存上的排列（内存从低到高）：78 |56 |34 |12
       a在大端法内存上的排列（内存从低到高）：12 |34 |45 |78
     - Intel兼容机多使用小端，ARM多为双端，但一旦确定系统（如iOS和Android支持小端），字节顺序也会确定
     - 网络传送二进制数据时需要确定网络协议
     - 字符串在内存中会以字节0x00结尾：
       字符串的解析以字节(内存的最小单位)为单位，按内存顺序解读，不存在大小端差

- 布尔代数的运算：~（取反）&（与运算）|（或运算）^（异或运算）

  - 推广到向量
  - 摩根率，分配率
  - 映射到集合

- c中的位运算统一做比特流的布尔(向量)运算，运算符同上，结果再进行十六进制化

- c中的逻辑运算有 ||, &&, ! 与位运算不同

  1. 逻辑运算的结果为一个布尔值，位运算得到bit流（布尔向量）
  2. 逻辑运算统一将输入视为布尔值：全零的比特流视为true；反之为false
  3. 逻辑运算走最短求值路径

- 位移运算：

  - 左移右补0
  - 逻辑右移左补0
  - 算数右移动(shlr)左补最高位
  - 有符号数右移用算数，无符号数右移用逻辑

## 2.2 整数

比特流的整数解释：

1. 映射到非负整数子集U
2. 映射到整数子集T

- 整数数据类型有char short int long type*
- B2U的编码： Umax = 2^w -1， 双射

$$
∑_{i=0}^{w-1}x_i·2^i
$$

- 补码编码：负数和非负数对称，Tmax = 2^(w-1)-1 Tmin = -2^(w-1) 最高位权重为负
- 扩展：无符号零扩展，有符号算数扩展
- 截断：取较低的位，舍弃较高的位

## 2.3 运算

overflow，minus-overflow Tmin的非就是Tmin（加法定义）

## 2.4 Float

with standard of IEEE 754

### 2.4.1 Binary float

对于一个二进制小数
$$
d_md_{m-1}···d_1d_0•d_{-1}d_{-2}···d_{-n+1}d_{-n}
$$
小组点左边为2的正权幂，右边为2的负权幂
$$
b = ∑^{m}_{i=-n}2^i{· }b_i
$$

### 2.4.2 IEEE 754

$$
V =(-1)^s · M · 2^ E
$$

表示一个浮点数：

- Sign: s(1bit)决定正负，0的符号位特殊处理
- M: significand 是一个2.4.1中的二进制小数，整数部分只会为1(Normal)或0(Denormal)，对对应长度比特流frac做尾数编码
- E: exponent 对M进行2的幂的加权，对对应长度比特流exp做阶码编码

> 单精度浮点32位，分为1(sign)+8(exp)+23(frac)
>
> 双精度浮点64位，分为1          +11      +52

![屏幕快照 2018-11-09 17.22.04](/Users/Miao/Desktop/屏幕快照 2018-11-09 17.22.04.png)

exp将浮点数分为三个类型

- Normalized: exp不是全0且不是全1的
  - exp偏置译码
    - exp先ones译码为无符号数e
    - 取Bias = 2^(k-1)-1
    - 译码结果E = e - Bias
  - frac 译为2的负权加1
    - M = 1.f1f2···fn
  - 浮点值 = V
- Denormalized: exp是全0的比特流
  - exp固定译码为E = 1-Bias (NM中E的最小值)
  - frac 直接译为2的负权
  - 浮点值 = V
- Abnormalized: exp是全1的比特流，用来表示特殊值
  - frac全为0时，视为正负无穷
    - %0时的溢出表示
  - frac非全0时，视为Not a Number(NaN)
    - 非实数或无穷非法运算的表示
    - 为初始化的数据表示

![屏幕快照 2018-11-09 17.22.47](/Users/Miao/Desktop/屏幕快照 2018-11-09 17.22.47.png)

### 2.4.3 数字示例

比特流映射到实数域内不是均匀分布的，Denormal在0附近分布密集，Denormal值均分布在0~+-2^(1-Bias)以内

浮点排序=其比特流的无符号排序，负数反之

### 2.4.4  舍入

round-to-even

### 2.4.5 浮点运算

没有结合律，单调性保持，精度溢出问题




















