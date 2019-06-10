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

