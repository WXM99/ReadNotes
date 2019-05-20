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

####  Integrity Constrains

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

   



