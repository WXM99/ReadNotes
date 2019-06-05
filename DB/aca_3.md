# MySQL Optimization

## 1. Query Cache

### 1. check

```sql
show variables like '%query_cache%' ;
+------------------------------+---------+
| Variable_name                | Value   |
+------------------------------+---------+
| have_query_cache             | YES     |
| query_cache_limit            | 1048576 |
| query_cache_min_res_unit     | 4096    |
| query_cache_size             | 1048576 |
| query_cache_strip_comments   | OFF     |
| query_cache_type             | ON      |
| query_cache_wlock_invalidate | OFF     |
+------------------------------+---------+
```

### 2. effect

![queryCacheOnUpdate](aca_3.assets/queryCacheOnUpdate-9700074.png)

update后失效

![queryCacheOnByte](aca_3.assets/queryCacheOnByte-9700074.png)

根据用户sql的字符串哈希

### 3. test



### 4. scheme

