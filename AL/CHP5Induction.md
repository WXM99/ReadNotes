# CHP5 Induction

- 正向思考：小规模问题到大规模
- 逆向递归：归纳假的解决设为真，扩展到大规模
- 递归算法设计（归纳，分治，DP）正确性证明同算法描述（利用归纳证明法）

## 5.2 简单的归纳法排序

SELECTIONSORT_REC和INSERTIONSORT_REC

### 5.2.1 选择排序

对数组A[1...n]假设已有sort A[2…n]的方法. 则现在A[1...n]找到最小值，与A[1]交换后调用sort A[2…n]

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

