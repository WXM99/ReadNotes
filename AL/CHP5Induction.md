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
  (1>n-1)∑j=n*(n-1)/2
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

