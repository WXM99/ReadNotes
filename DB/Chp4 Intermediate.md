# Chp4 Intermediate SQL

## 1. Constraints & Triggers

### 1.1 Motivation and Overview

- context: relational database
- SQL standard support, systems vary considerably
- Constraints: integrity constraints
  - constraint the **allowable states** of DB.
  - static concepts
- Trigers: 
  - monitor database changes
  - check conditions over the data and initiate actions
  - dynamic 

#### Integrity constraints

- Impose **restrictions** on allowable data

  > DDL中定义attr结构和类型不属于constraints

- Imposed by structure and types are not integrity constraints

- Integrity constraints are more **semantic**

  - capture restrictions
  - to do with application

- e.g.

  ```sql
  0.0 < GPA <|= 4.0
  student.HSsize < 2000 (=>) decision not 'Y' for college.enr > 30000  
  ```

- why use constraints

  - catch data-entry(inset) errors
  - correctness criteria (Update)
  - enforce consistency
  - tell the system about the data (optimize store and query)

- Classification

  - Non-null constraint
  - Key constraint (unique value in each tuple)
  - Referential integriy (foreign key) constraint
  - Attribute-based constraints (0 <= GPA <= 4.0)
  - Tupple-based constraints
  - General assertion (全局约束)

- Declare and Enforce

  - Declaration

    - with original schema

      checked after bulk loading

    - Later: checked on current DB

  - Enforcement

    - Check after every modification

    - Deferred constraint checking

      checfed every transaction

#### Triggers

> Event-Condtion-Action Rules
>
> When event occurs, check condition; if true, do action

- e.g.

  ```enrollment > 3500 => reject all application```

  or when insert or update

- Why triggers

  - Move logic was appearing in applications into the DB (?)
  - Enforce constraint (more expressive)
  - Constraint repair logic

- SQL

  ```sql
  create Trigger name
  Before|After|Instead of events
  [referencing-variables]
  [for each row]
  when (condition)
  action
  ```

### 1.2 Constraints

1. Non-NULL Constraints

   add ==not null== declaration when creating

   ```sql
   create table Students(
   	sID int, 
     sName text,
     GPA real not null,
     sizeHS int
   );
   ```

2. Key Constraints

   add ==primary key== or ==unique== declaration when creating

   ```sql
   create table Students(
   	sID int primary key, 
     sName text,
     GPA real,
     sizeHS int
   );
   ```

   > - multiple columns primary-keys: primary key (c1, c2 ...)
   > - duplicated null in unique is allowed, while pk columns not

   the values in the column as key must be unique

3. Attribute-based and tuple-based constraints

   - Attribute-based ==check== constraints 

   ```sql
   create table Students (
   	sID int,
     sName text,
     GPA real check(GPA <= 4.0 and GPA >= 0.0),
     sizeHS int check(sizeHS < 5000)
   );
   ```

   - Tuple-based constraints

     check at the end of the declaration

   ```sql
   create table Apply (
   	sID int,
     cName text,
     major text,
     decision text,
     check (
     	decision = 'N' or
       cName <> 'Stanford' or
       major <> 'CS'
     )
   );
   ```

4. General assertions

   ```sql
   create assertion Key
   check (
   	(select count(distinct A) from T) =
     (select count(*) from T)
   );
   ```

5. Referential Integrity

   subset dependency: ```attr_name varchar(20) references table_name```

   ```sql
   create table course (
   	...
     foreign key (dept_name) references departname
     	on delete cascade
     	on update cascade
     ...
   )
   ```

   # DSC Chp4

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













