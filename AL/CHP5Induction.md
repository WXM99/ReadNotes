# CHP5 Induction

- 正向思考：小规模问题到大规模
- 逆向递归：归纳假的解决设为真，扩展到大规模
- 递归算法设计（归纳，分治，DP）正确性证明同算法描述（利用归纳证明法）

## 5.2 简单的归纳法排序

SELECTIONSORT_REC和INSERTIONSORT_REC

### 5.2.1 选择排序

对数组A[1...n]假设已有sort A[2…n]的方法（靠后的n-1个元素）. 则现在A[1...n]找到最小值，与A[1]交换后调用sort A[2…n]

过程sort(i)

```pseudocode
def sort(i):
if i < n then
	k <- i
	for j <- i+1 to n
		if A[j] < A[k] then k<-j //扫描出最小元素
	end for
	if k!=j then swap(A[i],A[k]) //放回首位
	sort(i+1)                    //递归调用
end if
end def
sort(1)            //全局排序A[1...n]，调用sort(1)
```

全局排序A[1...n]，调用sort(1)

复杂度分析：

- 设比较次数为C(n), C(1) = 0;

-  n >= 2时比较次数为for循环中的数组最小值扫描和递归调用sort(n-1)比较次数之和，即
  $$
  C(n) = C(n-1) + (n-1)
  $$

- 由递推公式可以解得
  $$
  ∑_{1}^{n-1}j=n*(n-1)/2
  $$
  运行时间和比较次数是线性关系，故SELECTSORT_REC是Θ(n^2)的

### 5.2.2 插入排序

与SELECTSORT相反，当输入A[1…n]时，归纳假设为已知A[1...n-1]的排序过程（前n-1个元素），则当问题扩展时，只需要把A[n]插入到何时位置，并完成数组结构调整

```pseudocode
def sort(i):
	if i > 1 then
		x <- A[i]
		sort(i-1)
		j <- i-1
		while j>0 and A[j]>x  //倒叙查找
			A[j+1]<-A[j]      //后移一位
			j <- j-1          //焦点转移
		end while
		A[j+1] <- x           //插入最后一元素
	end if
end def
sort(n)
```

全局排序A[1...n]，调用sort(n)

复杂度分析：O(n^2) 最坏情况 完全逆序初始 o(n)最好情况 完全非降序初始

## 5.3 基数排序

从低位(底域)递归调用分发到桶在按序回收的操作

RADIXSORT 
待排表L={a1, a2, ..., an}, k个域

```pseudocode
for j <- i to k
	new bk0[],bk1[]...bk9[] //为各个域准备空桶
	while not l.empty()     //分发
		 a <- L[next]; delete a
		 i <- a[j]          //j域中a的值；
		 add a to bki[]
	end while
	for i <- 0 to 9         //回收
		add bki[] to L
 	end for
end for                     //到高域充分发回收
return L
```

利用迭代完成递归操作，动态维护回收过程
时间复杂度Θ(n)； 空间复杂度Θ(n).

## 5.4 整数幂

求实数x的n次幂的算法

- Low: 迭代法自乘n次，乘法次数为theta(n)，计算量是指数的复杂度

- Effective: m = [n/2]取下整，在已经知道计算x^m的归纳假设下，可以求出x^n = (x^m)^2 or ( (x^m)^2)*x 取决于n的奇偶：

  - 递归算法EXP_REC:

  ```pseudocode
  def power(x,m):
  	if m == 0 then y <- 1
  	else
  		y <- power(x,[m/2]d)
  		y <- y*y
  		if odd(m) then y <- x*y
  	end if
  	return y
  end def
  call power(x,n)
  ```

  - EXP_REC乘法次数为theta(logn)，计算量为输入的线性
  - 可改写为迭代算法EXP：
    - 设n的二进制码向量为[dk-1,..., d0]。从基数y为1开始从最高位到最低位扫描，ds=1则y=yy; ds=0则y=yyx

  ```pseudocode
  y <- 1
  n = bin[dk,dk-1,...,ds,...,d0]
  for j <- k downto 0
  	y <- y*y
  	if dj == 1 then y = xy
  end for
  return y
  ```

  - 运行时间为theta(logn)，对于输入的大小是线性的

## 5.5 多项式求值（Horner规则）

给定n+2个实数a0, a1, ..., an,x，要对多项式
$$
P_n(x)=a_{n}x^n+a_{n-1}x^{n-1}+...+a_1x+a_0
$$
分别每项计算再求和的需要的乘法次数为theta(n^2)的（或者为theta(nlogn)在各项运用rec再求和）

- Honrer规则：在已经知道Pn-1(x)的计算方法时在运用一次乘法和加法
  $$
  P_n(x) = x·P_{n-1}(x)+a_0
  $$
  归纳展开
  $$
  P_n(x)=((...(((a_nx+a_{n-1})x+a_{n-2})x+a_{n-3})...+a_1)x+a_0
  $$
  算法HORNER

  ```pseudocode
  p <- an
  for j <- 1 to n
  	p <- x*p + an-j
  end for
  return p
  ```

  操作递归方程为C(n) = C(n-1) + (n-1)，C(n) = 2*n. n次乘法和n次加法使复杂度退化为theta(n).

## 5.6 生成排序(Permutation)

对于生成1, 2, ..., n的全排列，用数组P来存放一种排列；归纳法解决的假设为：可以生成n-1个数的全排列

###  算法1. 递归深度

在可以生成n-1的全排列下，生成n个数的全排列做法为：

1. 生成 2, 3..., n 的所有排列，并在前加入1；
2. 生成 1, 3..., n 的所有排列，并在前加入2；

  n.  生成1, 2,..., n-1的全排列，并在前加入n;

```pseudocode
def perml(m):
	if m == n then output P
	else
		for j <- m to n
			swap(pj, pm) //头插1...n,构造不同的P(n-1)
			perml(m+1)   //Rec 全拍P(n-1)
			swap(pj, pm) //复原为下一次构造
		end for
	end if
end def
#PERMUTATION1
for j <- 1 to n
	P[j] <- j
end for
perml(1)
```

- 时间复杂度分析：
  在perml()的for循环中，第一次共执行了n次perm(2)和2n次swap(复杂度简记为n)，可得出操作次数f(n)的递归方程为：
  $$
  f(n)=\left\{
  \begin{aligned}0, n=1\\
  nf(n-1)+n, n ≥ 2\\
  \end{aligned}
  \right.
  $$
  利用辅助函数h(n) = n!f(n)可以解得操作的复杂度为theta(n*n!)

### 算法2. 填补自由域(index)

对于一个初始为全部自由项的数组P(n)，同样基于知道生成P(n-1)全排列的方法的归纳假设：

1. 从首位填补自由项为n，直到最后一位
2. 每次填补后，在省下的自由域中再利用P(n-1)算法填充
3. 无自由项时，即为一种排列，输出
4. 填补下一个自由项前，归还当前位置到自由域

```pseudocode
#PERMUTATION2
def perml(m):
	if m == 0 then output P[n]
	else
		for j <- i 1 to n
			if p[j] = 0 then  // 自由位置
				P[j] <- m     // 从高位填补
                perml(m-1)    // rec填补余下
                p[j] <- 0     // 归还自由空间
            end if 
        end for 
    end if
end def

#初始化P[n]为完全自由空间(0)
perml(n)
```

- 复杂度分析：

  递归方程
  $$
  f(m)=\left\{
  \begin{aligned}0, m=1\\
  mf(m-1)+SIZE, m ≥ 2\\
  \end{aligned}
  \right.
  $$
  解得操作的复杂度是theta(n*n!)的

## 5.7 Find Majority



















