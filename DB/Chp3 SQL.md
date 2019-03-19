# Chp3 SQL

> **FOR RELATIONAL DATABASE**
>
> based on relational algebra
>
> Structured Query Language

## DDL

```sql
create
drop
```



## DML

```sql
select
insert
delete
update
```

- Basic SELECT Statement

  ```sql
  Select A1, A2, ..., An # clause No.3
  From R1, R2, ..., Rm  # clause No.1
  Where condition # clause No.2
  ```

  - From: the relation that should be queried over;
  - Condition: conbine the relations and to filter the ralations;
  - Select: what (attr) to return;

  Equivalent to: 
  $$
  Π_{A_1, A_2,...A_n}(σ_{condition}(R_1×R_2×...×R_m))
  $$
  From => ×

  Where => σ

  Select => Π

  - distinct: make result from bag to set
  - order by (desc, acse)
  - like '%', '_':  
    - "%" free string match
    - "_" not null match
  - \*  (star): all attrs
  - arithmetic calculation
  - as (rename select clause)

- Table variables (from clause, space + rename)

  - in the from clause
  - make queries more readable 
  - rename relations used in from clause 
  - **rename for 2 instance of the same relation **

- Set operators

  - Union : connect two (result) relations
  - Intersect: Self Join to substitute
  - Except (minus): unsubstitute

- sub-queries in "where"

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

    

