# Chp7 E-R model

## UML Data modeling

> - Data modeling:
>
>   how to represent data for application
>
> - Database design model
>
>   - Not implemented by system
>   - Tanslated into model of DBMS
>
> ```high-level data model -> translator -> relations -> RDBMS```

### High-Level Database Design Models

- Entity-Relation Model (E/R)
- Unified Modeling Language (UML)
- Graphical
- Relations translatable

### UML Data Modeling

1. Classes

   - Name
   - Attributes: primary key (adj)
   - Methods: dropped in data-relation model

2. Association

   - Relations between objects of two classes

   - Multiplicity of Associations (关系基数)

     default 1..1; no restriction: 0..*; m to n: m..n

   - Types of Relationships

   > - One2One
   >
   >   不约束每个class都参与
   >
   >   但参与的class必然是一一对应的 (婚姻关系)
   >
   >   (wife) 0..1 <---> 0..1 (husband) 为零代表丧偶
   >
   > - Many2One
   >
   >   某一方联系的上限为1 (学生只能属于一个学校或者辍学0)
   >
   >   另一方没有限制(学校拥有无限制个学生)
   >
   >   \(Student) *  <----> 0..1 (University)   
   >
   > - Many2Many
   >
   >   没有基数限制的联系 (老师与学生)
   >
   >   \*<---->*
   >
   > - Complete
   >
   >   完全参与关系, 没有0关系
   >
   >   complete one 2 one: 1..1 <---> 1..1
   >
   >   complete many 2 one: 1..* <---> 1..1
   >
   >   complete many 2 many: 1..* <---> 1..*

3. Association Classes

   - Association with attributes on relationships

   - Eliminating in 0..1 or 1..1 multiplicity

     用含有唯一另一方的类的外键和附加属性表示

   - Self-Association

     Association between a class and itself

     同类型实例之间的关系 (同学之间的朋友关系)

4. Subclasses

   某个类的衍生类. 集成基类的属性, 可以增加属性

   Superclass = Generalization

   Subclass = Specialization

   Complete subclass relationship: 每个基类的实例都有至少属于子类; 相反的称为incomplete or partial (局部的)

   Disjoint subclass relationship: 每个实例都只能作为唯一一个子类的实例; 如果一个实例可以同时作为多个子类对象的实例, 则为overlapping

5. Composition & Aggregation

   Composition: 一个类的实例从属于另一个类, 则这两个类是Composition; 从属类对被聚合类是1..1的

   Aggregation: 可以独立的从属关系, 从属类对聚合类是0..1的