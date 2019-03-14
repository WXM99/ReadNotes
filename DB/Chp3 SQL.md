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

  - distinct
  - order by (desc, acse)
  - like '%' '_'
  - *star
  - as (rename)

