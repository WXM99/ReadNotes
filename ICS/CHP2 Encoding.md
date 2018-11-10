# CHP2 Encoding

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

比特流映射到实数域内不是均匀分布的，Denormal在0附近分布密集，Denormal值均在0的2^(1-Bias)以内

浮点排序=其比特流的无符号排序，负数反之

### 2.4.4  舍入

round-to-even

### 2.4.5 浮点运算

没有结合律，单调性保持，精度溢出问题




















