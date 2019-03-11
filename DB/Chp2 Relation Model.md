# Chp2 Relation Model

## 关系模型

### 关系数据结构 (Table)

- ✖️(Cartesian Product, 笛卡尔积)

  - Def

    Domains:

  $$
  D_1,D_2,D_3...D_n
  $$

  ​	(Duplicated Domains are allowd)

  ​	The Cartsian Product is:
  $$
  D_1×D_2×D_3×...×D_n=\{(d_1, d_2, d_3...,d_n) | d_i∈D_i, i=1,2,3,...,n\}
  $$

  - 所有算子域的所有取值的全组合, 计算结果可视为Relation的域
  - Cardinal Number (基数, 大小, tuple数) 为各个算子域基数(大小)连乘

- 单一的数据结构 —— 关系

  - 一些域的笛卡尔积的子集, 为这些域上的关系

    R(D1, D2,..., Dn)

    - R : 关系名
    - n: 关系的目 (Degree)
      - n=1: Unary relation
      - n=2: Binary relation

  - 表示Entities (**Teacher**, **Students**, etc.)

  - Entities之间的各种来联系 (/students/ **Take** /course/)
  - Tuple: 关系中的每个元素(n-tuple)
  - Attribute: 每个列的名字(数量为n)
    - Key (码)
      - Candidate key
      - All key
  - Prop:
    -  Homogeneous: 列是同质的
    - 行列顺序可变
    - 分量原子性

- Schema (关系模式):

  - Def: Shape of relation R(**U**, D, DOM, F)

    > R: 关系名; U:属性名集合; D:属性域;
    > DOM: 属性域映像集合; F: 属性间数据依赖关系  

    - Attributes defination
    - Domain defination
    - Redlaction between domains

### 关系完整性约束

#### Entity Integrity 实体完整性 (必要)

- **主属性(主码)不能为null** (unknow)

#### Referential Integrity 参照完整性 (必要)

- 外键在被参照关系中必须是(主)码(或是null)

#### 用户定义完整性

- Domain人为归约

## 关系代数

> 代数的域: 计算对象为关系, 计算结果仍然是关系

#### 集合运算 (将关系视为tuple元素的集合)

- 属于: t∈R (t是R关系中的一个tuple)
- 属性分量: t[Ai], t.Ai (t这个元组在Ai属性上的值)
- 属性组 属性列: A (关系中所有属性或者是一部分)
- 属性分量集合: t[A], t在属性组A上的分量集合
- 属性组补: A_bar, A在所有属性里的补集
- 元组串接: 元组目数相加, 合并为一个
- 象集: Z_x (X属性上取值为x的各个tuple在Z属性上的分量集合)

- 并: ∪ (目数相同, 对应属性域相同 —— 同质关系)

- 差: - (同质关系, 属于前者但不属于后者的tuple集合成的relation)

- 交: ∩ (同质)

- 笛卡尔积: × (无需同质, 两关系中所有tuple组合串接后并集对应关系)

  目数相加; 基数相乘

#### 专有运算

- Select 选择: σ_F

  在关系中选出满足谓词F的tuple, 构成一个集合, 作为relation

  F = X1 θ X2 (θ可以是 >, >=, <, <=, =, <>)

- Projection 投影: π_A(R)={t[A] | t ∈R}

  在关系中选出特定的属性组A中值构成的tuple集合, 作为relation

  新的relation中剔除重复tuple

- Join 连接: R🔗 (AθB)S = {ts^tr | tr∈R & ts∈S & tr[A] θ ts[B]}

  从关系间的笛卡尔积中选择出满足谓词的元组构成集合, 作为relation

  A, B分别为R, S关系上数目相等并且可以比较的属性组

  - EquiJoin等值连接(θ为=)

  - Natural join自然连接

    A, B虽然分属R, S, 实际上为同一个属性

    做等值连接后去掉该属性列(π_(U-R))

  - 悬浮元组 (Dangling Tuple)

    连接时不满足θ的元组 (结果中被舍弃的元组)

  - Outer Join

    悬浮元组保留在结果中, 新加入属性用null占位

    左外连接: 只保留左表的DT; 右外连接同理

- 除: ➗

  Y是两个关系的共有属性(组), X是被除表属性集中Y的补集

  选中一些元组需要满足: 当某些tuple t.X=x1,  这些tuple (t.Y属性上的分量集合)需要**包含**S表在Y的投影; t.X 依次取x1, x2 ... 

  这些元组再投影在X上, 即{xi1, xi2, ...}