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

    - Homogeneous: 列是同质的
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

# DSC Chp3

## DML

```sql
create table _table_name 
( 
  _attr_name type,
  _attr_name type,
  ...
  <constraint>,
  <constraint>,
  ...
);
```

## 附加运算：

1. Rename:

   ```sql
   old_name as new_name 
   ```

   在select中：改变属性名

   在from中： 改变关系名

2. Strings util

   ``upper(s)``, ``lower(s)``, ``trim(s)``

   ``like``: %通配，包括空字符，_任意一个字符， \转义escape定义

## 集合运算

union：并集，all不去重复

intersect：交集，all不去重复，重复次数为两个table中独立重复次数少的次数

except：差集，all不去重复，重复项为两个table中独立重复次数的差

## 空值

谓词先手逻辑判断，代数有空则空

distinct去除重复空值，然而谓词null = null是unknown

## 聚集函数

avg，min，max，sum，count

select中出现的，没有被聚集的属性，只能再次出现在group by子句中 => 聚集单值性

## having

group by 之后的谓词选择，属性单值

## 用于table的谓词

table产生于嵌套子查询

成员存在： in，可以接枚举集合(A， B)

集合比较：单值与集合的谓词，利用some(exist) any(all)修饰集合

in <=> = some; not in <=> <> any

eixts：子查询非空谓词

unique：子查询无重复谓词

一般子查询需要外层查询传参(rename)

## from 子句中的子查询

方便两次where谓词筛选

## with as子句

定义临时表,可以定义多个在下文查询中使用

## 标量子查询

返回单值,在select, where, having子句中

## 修改

### alter table _table_name  add _attr _domain

### alter table _table_name  drop _attr

### delete from _relation where

统一测试, 统一删除

### drop table _relation

### insert into relation values(...)

insert into relation (查询子句): 先计算查询结果, 统一插入

### update relation set attr = new_attr where

```sql
set attr = case 
				when … then … 
				when … then … 
				else … 
			end

set attr = --{{标量子句查询}}
```

### sub-queries in "where"



- sub-query: nested select statement

  ```sql
  SELECT sID, sName
  FROM Student
  WHERE sID in (     # "in" is a set operator
  	SELECT sID 
      FROM Apply
      WHERE major = "CS"
  );
  ```

- sub-query substituted by Joining 

  ```sql
  SELECT DISTINCT Student.sID, sName
  FROM Student, Apply
  WHERE Student.sID = Applt.sID and major = "CS";
  ```

- except substituted by sub-query

  ```sql
  SELECT sID, sName
  FROM Student
  WHERE sID in (
  	SELECT sID
      FROM Apply
      WHERE major = "CS"
  ) and sID not in (
  	SELECT sID
      FROM Apply
      WHERE major = "EE"
  )
  ```

- EXIST to sub-query to test empty

  ```sql
  SELECT cName, state
  FROM College C1
  WHERE exists (
  	SELECT * 
      FROM College C2
      WHERE C2.state = C1.state
      and C1.cName <> C2.cName
  ) 
  ```

- sub-query substitute MAX

  ```sql
  SELECT cName 
  FROM College C1
  WHERE not exists (
  	SELECT * from College C2
      WHERE C2.enrollment > C1.enrollment
  )
  ###or
  SELECT S1.Sname, S1.GPA
  FROM Student S1,Student S2
  WHERE S1.GPA > all(S2.GPA)
  ```

### sub-queries in the FROM and SELECT

- in FROM

  ```sql
  SELECT *
  FROM (
  	select sID, sName, GPA, GPA*(sizeHS/1000.0) as scGPA
    from Student
  	) as new_Student
  WHERE abs(new_Student.scGPA-GPA) > 1.0;	
  ```

- in SELECT

  ```sql
  SELECT cName, state, 
  	(
      select distinct GPA
      from Apply, Student
      where College.cname = Apply.cname
      	and Apply.sID = Student.sID
      	and GPA >= all
      		(
            select GPA 
            from Student, Apply
            where Student.sID = Apply.sID
            	and Apply.cName = College.cName
  	      )
    ) as MaxGPA
  FROM College;  
  ```

- Sub-queries in SELECT must return **one value** (single column)

  because the the value is used to fill in just one row of the result.

  select中的sub-query必须返回单值

1. # DSC Chp4

## Join

- join
  - (inner) join
    - on
    - using
  - outer join
    - left 
    - right
    - full
- outer join: on || where
  - 连接条件必须在on中, 否则on 为 on true, 变为笛卡尔积, 不会补充含有null的一行

## view

虚关系 — query的宏定义

不是逻辑模型的组成, 但是用户可见的关系

可以出现在任何关系名出现的地方, 包括view定义

物化视图: 实际储存关系, 需要维护

view可更新的条件

- from中只有一个表
- select中只有属性名
- 没有出现在select上的关系可以为null
- 没有group by和having子句

## transaction

不可分的动作序列

由其中第一个sql语句开始, commit work(完成) 或者 rollback work(错误回滚) 结束

begin atomic … end

## Integrity Constraint

修改不会破坏数据库的一致性

alter table _table_name add _constraint

### 单关系约束

作用在一个table

- not null
- unique: null视为不同
- check(谓词): 以tuple为单位, check每一个tuple满足谓词

### 参照完整性

外键引用的实体存在性:

- 引用外键关系中的属性集子集取值, 必须是被引用关系中的==存在的值==, 此时属性集称为外码
- 外码参照要求==存在的值==为被参照关系的==主码==

可以定义参照constraint:

```sql
foreign key(_attr) references _relation
```

(_attr是两个table中相同的属性名)

### cascade

添加参照完整性约束时, 补充选项

```sql
foreign key(_attr) references _relation
	on delete cascade
	on update cascade
```

连级删除或者连级更新: 参照关系改变后, 被参照关系随之改变

可以用set null替代cascade

cascade最多支持一步连级操作, 否则终止事务并撤销

外键可以是null, null满足参照完整性约束

### 事务违反约束

``initially deferred``修饰约束: 事务结束后检查约束

``set constraints _constraint_name deferred`` 可以在事务中设置

默认立即检查约束

# DSC Chp5

## 函数和过程

将业务逻辑储存在DB内并执行: 允许多个进程访问; 做到应用和数据库解耦合;

### SQL标准语法

游标: 

```sql
declare cursor _cur_name for _query
open _cur_name
fetch _cur_name into _var  --one tuple
-- fetch every tuples
while ....
 fetch _cur_name into _var
end while
close _cur_name
```

函数: 返回单值or table (表函数). 函数内参数带函数名前缀

过程: in out call

declare: 声明变量, 任何类型

set: 变量赋值

复合语句: begin-end

迭代语句: while for

逻辑分支: if-else then case-when

异常流: condition-handler(exit || cont)-signal

## 触发器

create trigger _name 

- after (before)  --alter
- on _table_name ( _attr of _table_name )
  - referencing new (old) row (table) as _temp_name 
  - for each row (statement)
  - when _condition
    - begin
      - _do_things
    - end

## Samples

```sql
use university;

drop function if exists teacher_salary;
delimiter //
create function teacher_salary (this_dept_name varchar(20))
returns decimal(8,2)
begin
    DECLARE done INT DEFAULT FALSE;
    declare total decimal(8,2) default 0.0;
    declare cur_salary decimal(8,2);

    declare cur CURSOR for
      select salary
      from instructor
      where instructor.dept_name = this_dept_name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    open cur;

    read_loop: loop
    fetch from cur into cur_salary;
    if done then
        leave read_loop;
    end if;
    set total = total + cur_salary;
    end loop;
    close cur;
    return total;
end//
delimiter ;

select dept_name, teacher_salary(dept_name) from department;

drop function teacher_salary;
```

```sql
use university;

drop function if exists schoolarship_res;
drop table if exists scholarship_temp;
drop view if exists class_sum_result;

create view class_sum_result as
select ID, name, dept_name,
    sum(grade='A+' or grade='A') as 'A/A+',
    sum(grade like 'A%') as 'A class',
    sum(grade like 'C%') as 'C class'
from takes natural join student group by ID;

create temporary table scholarship_temp
    (
        dept_name		varchar(20),
        level           char(1),
        s_ID			varchar(5),
        s_name			varchar(20),
        A_num           int
    );

delimiter //
create function schoolarship_res()
returns integer
begin
  declare temp_dept varchar(20);
  declare temp_id varchar(5);
  declare temp_name varchar(20);
  declare temp_aaplus int;
  declare temp_a_num int;
  declare temp_c_num int;

  DECLARE done INT DEFAULT FALSE;
  declare cur CURSOR for
    select * from class_sum_result;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  open cur;

  read_loop: loop
    if done then
        leave read_loop;
    end if;
    fetch from cur into
      temp_id, temp_name, temp_dept,
      temp_aaplus, temp_a_num, temp_c_num;
    if temp_aaplus >= 2 then
      insert into scholarship_temp
      values (temp_dept, 'A', temp_id, temp_name, temp_a_num);
    elseif temp_aaplus >= 1 and temp_c_num = 0 then
      insert into scholarship_temp
      values (temp_dept, 'B', temp_id, temp_name, temp_a_num);
    end if;
  end loop;
  close cur;
  return 0;
end //

delimiter ;
do schoolarship_res();
select * from scholarship_temp;

drop temporary table scholarship_temp;
drop view class_sum_result;
drop function schoolarship_res;
```

# Chp8 **Relational Database Design**

## 1FN

atomic attr: 

根据使用情况

- 如果对Attr进行拆分, 解析并使用 — 违反1FN

  ID = CS0012, CS + 0012 

- 对Attr进行整体使用, 不非凡

  ID = SE123, 不可拆分

## 2NF

### 非主属性不能依赖于主码的真子集

## FD: function dependency

- A -> B => f(A) = B

- A, B之前有函数映射关系: 

  没给定一个A. R中都能找到唯一一个B与之出现在同一个tuple

- 任意属性 FD SuperKey (SuperKey在Relation中只出现一次)

## Closure

### 函数依赖的闭包

一个Relation中所有FD集合

通过已知FD求Closure: Armstrong’s Axiom

![image-20190614231853361](../../../../../Mobile%20Documents/com~apple~CloudDocs/GitHub/ReadNotes/DB/ch8RelationalDatabaseDesign.assets/image-20190614231853361.png)

### 属性集的闭包

计算被给定属性集确定的属性集合

- 在函数依赖闭包中找到左侧为给定属性集的, 右侧集合为其闭包

- 设属性集A在给定函数依赖集F上的闭包为A^+^: Ap

  ```pseudocode
  Ap := A
  repeat
  	for each m -> n in F do
  	begin
  		if m in Ap then 
  			Ap := Ap ∪ n
  		end if
  	end
  until const Ap  
  ```

### 正则覆盖

更新DB后, 需要检测FD是否依然满足

FD过大则检测开销过大, 需要构造一个更小的简化集, 与原集有相同闭包

满足简化集则一定满足原集

- 无关属性: 去除后不改变FD的闭包.

  设原集F有FD: α -> β

  - A∈α && F蕴含了 (F - {α -> β}) ∪ {(α-A) -> β} 

    **(α-A) -> β 可以通过F得到**

  - A∈β && (F - {α -> β}) ∪ {α ->(β-A)} 蕴含了F

    **(F - {α -> β}) ∪ {α ->(β-A)} (F去掉A) 得到α -> A**

  则A是无关属性

- 正则覆盖: F~c~与F相互蕴含所有FD

  - Fc不含有任何无关属性
  - 左边属性集唯一出现

  ```pseudocode
  Fc = F
  repeat
  	运用合并率
  	找到无关属性, 删除之
  	去除相同FD
  until const Fc
  ```

### 无损分解

R~1~, R~2~替代R没有信息损失, 则分解是无损的

**π~R1~(R) natual join π~R2~(R) = R**

必须是相等, 结构不同不可, 规模不同也不可

R1, R2, R为属性集, 无损分解 <=

- R1 ∩ R2 -> R1 ∈ F^+^ ||
- R1 ∩ R2 -> R2 ∈ F^+^
- R1 ∩ R2 是R1或R2的超码

## BCNF: Boyee-Codd 

对于Closure中的所有FD: 

- FD是平凡的 ||
- FD自变attrs是超码

自变量attrs不是超码则对其分解 如A -> B

- R1 = A ∪ B
- R2 = R - (B - A)

分解直到满足BCNF

## 保持依赖

- 限定:  闭包中, 只关于某个分解的属性的FDs.
- 保持依赖: 限定并集的闭包等于原闭包

对F中的一个FD: A -> B, 验证保持性:

```pseudocode
result := A
repeat
	for each Ri
		t = (result ∩ Ri).closure ∩ Ri
		result = result ∪ t;
	end for
until const result
```

如果result包含B的所偶属性 => A-> B 保持

原有的依赖能够在同一个R中体现

### e.g. 

R(A, B, C) 有 A -> B, BC -> A

BC是candidate key. A不是超码 A->B不符合

分解为:

- R1 = (A, B)
- R2 = (A, C)

原有依赖: BC->A 没有体现, 不是依赖保持的

## 3NF

为了解决BCNF不能保持依赖的问题, 对BC放宽了

对于Closure中的所有FD: 

- FD是平凡的 ||
- FD自变量attrs是超码 ||
- **因变量attrs与自变量attrs的差集包含于一个候选码中**

放宽的条件保证了每一个schema都可以有保持依赖的3NF分解

### e.g. 

R(A, B, C) 有 A -> B, BC -> A

BC是candidate key. A不是超码 A->B不符合

B - A = B; B ∈ BC => 满足3NF

=> R(A, B, C) 是满足3NF的

## 分解算法

### BCNF分解

![image-20190615142522915](../../../../../Mobile%20Documents/com~apple~CloudDocs/GitHub/ReadNotes/DB/ch8RelationalDatabaseDesign.assets/image-20190615142522915.png)

### 3NF分解

![image-20190615142634153](../../../../../Mobile%20Documents/com~apple~CloudDocs/GitHub/ReadNotes/DB/ch8RelationalDatabaseDesign.assets/image-20190615142634153.png)

## MVD

要求某种形式的其他元组存在, 也叫元组存在依赖

A ->-> B 成立

iff

对R中任意两个元组t~1~, t~2~

若t~1~[A] = t~2~[A] 

则R中存在t~3~, t~4~

有

t~1~[A] = t~2~[A] = t~3~[A] =t~4~[A]

t~1~[B] = t~3~[B] 

t~2~[R-B] = t~3~[R-B] 

t~2~[B]=t~4~[B]

t~2~[R-B]=t~4~[R-B]

- A, B之间的联系独立于A和R-B之间联系
- 在A一定时, B与R-A-B独立意味着二者之前存在全组合

|      |  A   |  B   | R-A-B |
| :--: | :--: | :--: | :---: |
| t~1~ |  a   |  b   |   d   |
| t~2~ |  a   |  c   |   e   |
| t~3~ |  a   |  b   |   e   |
| t~4~ |  a   |  c   |   d   |

- 平凡多值依赖: B包含于A || B∪A=R (R-B-A包含于A)
- A->B => A->->B
- A->->B => A->->R-A-B

## 4NF

闭包中所有的MVD, A->->B

- A->->B是平凡的
- A是R的超码

=> Agree on 4NF

4NF是BCNF加强

# Chp14 Transaction

## 定义

全部发生, 或者全部不发生的一组操作单元集合

```sql
begin transaction
-- sql
end transaction
```

- atomic 原子性: 任何失败都要撤销操作, 保证执行单元的“全或无”
- consistency 一致性: 数据库信息熵守恒
- isolation 隔离性: 事物的执行, 不能看作是被其他操作分隔开的; 不能被并发执行的操作干扰
- durability 持久性: 回复后事务操作持久

## isolation

### serializable

严格的串行化事务调度

### repeatable read

- 某个事务读取的数据项必须是别的事务已提交的, 否则读不到
- 事务内两次读取数据项期间, 其他事务不得更新该数据项

### read committed

- 某个事务读取的数据项必须是别的事务已提交的, 否则读不到
- 重复读相同数据项时不作要求

### read uncommitted 

- 可以读取别的事务未提交的数据项

### write

- 所有隔离级别不允许脏写: 其他没有完成事务写入的数据项,不得再次写

### 幻读

是指当事务不是独立执行时发生的一种现象，例如第一个事务对一个表中的数据进行了修改，这种修改涉及到表中的全部数据行。 同时，第二个事务也修改这个表中的数据，这种修改是向表中插入一行新数据。那么，以后就会发生操作第一个事务的用户发现表中还有没有修改的数据行，就好象 发生了幻觉一样。例如，一个编辑人员更改作者提交的文档，但当生产部门将其更改内容合并到该文档的主复本时，发现作者已将未编辑的新材料添加到该文档中。 如果在编辑人员和生产部门完成对原始文档的处理之前，任何人都不能将新材料添加到文档中，则可以避免该问题。

## 补充 

基于元数据的 Spring 声明性事务 :

Isolation 属性一共支持五种事务设置，具体介绍如下：

- READ_UNCOMMITTED 会出现脏读、不可重复读、幻读 ( 隔离级别最低，并发性能高 )
- READ_COMMITTED  会出现不可重复读、幻读问题（锁定正在读取的行）
- REPEATABLE_READ 会出幻读（锁定读取过的所有行）
- SERIALIZABLE 保证所有的情况不会发生（锁表）

**不可重复读的重点是修改** **:** 
同样的条件 ,   你读取过的数据 ,   再次读取出来发现值不一样了 
**幻读的重点在于新增或者删除** 
同样的条件 ,   第 1 次和第 2 次读出来的记录数不一样

![6474B6AFB6A3195E7B8090DA7B874F8A](../../../../../Mobile%20Documents/com~apple~CloudDocs/GitHub/ReadNotes/DB/Chp14Transaction.assets/6474B6AFB6A3195E7B8090DA7B874F8A.png)

### 共享锁【S锁】

又称读锁，若事务T对数据对象A加上S锁，则事务T可以读A但不能修改A，其他事务只能再对A加S锁，而不能加X锁，直到T释放A上的S锁。**这保证了其他事务可以读A，但在T释放A上的S锁之前不能对A做任何修改(除了自己修改)。**

### 排他锁【X锁】

又称写锁。若事务T对数据对象A加上X锁，事务T可以读A也可以修改A，其他事务不能再对A加任何锁，直到T释放A上的锁。**这保证了其他非uncommitted事务在T释放A上的锁之前不能再读取和修改A。**

```sql
use university;
(
  select dept_name as Department, "Instructor" as Type, count(*) as Count
  from instructor
  group by dept_name
) union
(
  select dept_name as Department, "Student" as Type, count(*) as Count
  from student
  group by dept_name
) union 
(
  select dept_name as Department, "Instuctor" as Type, 0 as Count
  from (
    select dept_name from
    ( select department.dept_name, id
      from department left outer join instructor 
     	on department.dept_name = instructor.dept_name
    ) as wn
      where id is null
    ) as di
)
order by Department;

use university;
SELECT
    dept_name,
    COUNT(IF(TYPE = 'Student', TRUE, NULL)) AS studentNum,
    COUNT(IF(TYPE = 'Instructor', TRUE, NULL)) AS teacherNum
FROM((
      SELECT ID, 'Student' AS TYPE, dept_name
      FROM student)
    UNION
    ( SELECT ID, 'Instructor' AS TYPE, dept_name
    FROM instructor)
) as total
GROUP BY
total.dept_name;
```
