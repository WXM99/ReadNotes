# Chp5 Advanced SQL

## Functions and Procedures

### Declaration of function

```sql
create function dept_count (dept_name varchar(20))
	returns integer
	begin
	declare d_count integer;
		select count(*) into d_count
		from instructor
		where instructor.dept_name = dept_name
	return d_count
	end
```

Table functions: return a table, ==parameterized view==

```sql
create function instructor_of(dept_name varchar(20))
	returns table (
  	ID varchar(5),
    name varchar(20),
    dept_name varchar(20),
    salary numeric(8, 2)
  )
  return table 
  (
  	select ID, name, dept_namem salary
    from instructor
    where instuctor.dept_name = instructor_of.dept_name
  );
```

使用参数添加函数名前缀: ==instructor_of.dept_name==

### Procedure

```sql
create procedure dept_count_proc(in dept_name varchar(20), out d_count integer)
	begin 
		select count(*) into d_count
		from instructor
		where instuctor.dept_name = dept_count_proc.dept_name
	end
```

in: 传入参数; out: 赋值参数

调用过程:

```sql
declare d_count integer;
call dept_count_proc('Physics', d_count)
```

### Logic Control Flow

1. While

   ```sql
   while boolean_exp do
   	seq_exp
   end while
   
   repeat
    seq_exp
   until boolean_exp
   end repeat
   ```

   

2. for

   ```sql
   declare n integer default 0
   for r as 
   	select budget from department
   	where dept_name = 'Music'
   do 
   	set n = n + r.budget
   end for
   ```



## Trigger

- Condition
- Handle

create trigger _name 

- after (before) [alter] 
- on _table_name ( _attr of _table_name )
  - referencing new (old) row (table) as _temp_name 
  - for each row (statement)
  - when _condition
  - begin
    - _do_things
  - end

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

