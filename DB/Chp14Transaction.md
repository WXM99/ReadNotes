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

### read commit

- 某个事务读取的数据项必须是别的事务已提交的, 否则读不到
- 重复读相同数据项时不作要求

### read uncommitted 

- 可以读取别的事务未提交的数据项

### write

- 所有隔离级别不允许脏写: 其他没有完成事务写入的数据项,不得再次写

## SQL





