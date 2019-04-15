use university;

# 3.1.a
select title
from course
where dept_name = 'Comp. Sci.' and credits = 3;
# 3.1.b
select distinct student.ID
from student join advisor on student.ID = advisor.s_ID
where i_ID in
      (
        select ID
        from instructor
        where name = 'Einstein'
      );
# 3.1.c
select max(salary)
from instructor;
# 3.1.d
select *
from instructor
where salary in (
  select max(salary)
  from instructor
  );
# 3.1.e
select t.course_id, t.sec_id,count(distinct student.ID)
from (student inner join takes t on student.ID = t.ID) inner join section on t.course_id = section.course_id
where section.year = 2009
group by t.course_id, t.sec_id;
# 3.1.f
select max(T.tot_st)
from (
  select t.course_id, t.sec_id,count(student.ID) as tot_st
  from (student inner join takes t on student.ID = t.ID) inner join section on t.course_id = section.course_id
  where section.year = 2009
  group by t.course_id, t.sec_id
  ) as T;