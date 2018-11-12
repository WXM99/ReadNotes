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

- 



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




















