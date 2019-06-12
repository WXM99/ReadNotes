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

## serializable



