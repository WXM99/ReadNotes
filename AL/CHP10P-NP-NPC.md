# CHP10 P-NP-NPC

- Decision problem（判定问题）: ret YES or NOPE
- Optimization problem（优化问题）: the minimization or maximum in a list of element
- D&O could be modified reciprocally



## 〇 The Class P

- ### *Def* Deterministic Algorithm

  > - Algorithm A can sovle proble Π. 
  > - Presented with an instance of the problem Π, A has **only** **one choice in each step** throughout its execution.
  > - A is run again and again on the same Π, **output never change**.
  > - **A is a Deterministic Algorithm**

- ### *Def* **Class of Decision Problems P** (polynomial)

  > - The solution of problems in the class of P (YES/NOPE) can be  obtained using a **Deterministic Algorithm** 
  > - The algorithm runs in **polynomial number of steps**.

- ### e.g.

  - [SortTable, UnionFind, ShortestPath]

  - 2-COLORING problem: 

    > - ALG: 2-COLORING
    >
    > - INPUT:  An undirected graph G
    >
    > - OUTPUT: Can G be colored with 2 colors.
    >
    >   if G is **bipartite** （二分图）
    >   ​	if G **doesn't contain cycles of odd length**
    >   ​		return true
    >   ​        else return false
    >   ​        end if
    >
    >   else return false
    >   end if

  - 2-SAT problem:

    >

- ### *Def* Complementation Problem

  > An problem opposites to the given deterministic one. 

- ### *Def* Closed Under Complementation

  > - A given class of problems *C*.
  > - For any problem Π **∈** *C*, Π's complementation problem Π' ∈ *C* too.
  > - The class *C* is closed under complementation. 

- ### *Theorem*

  > **The Class P is closed under complementation**



## 〇 The Class NP

- ### *Def* Class NP (informalized)

  > - A given class of problem made of Π.
  > - A given deterministic algorithm *A*.
  > - *A* check the correctness of a claimed solution of and instance of Π in polynomial time.
  > - Π is belong to the NP class.

- ### *Def* Nondeterministic Algorithm

  > On input x, NDA (*Nondeterministic Algorithm*) contains two phases:
  >
  > - (a) The guessing phase
  >
  >   - Generate an arbitrary string y.
  >
  >   - Generation requires x's polynomial steps.
  >
  > - (b) The varification phase.
  >
  >   - Check solution string *y* is in the proper format. If isn't, halt with answer nope.
  >   - Check solution is true for instance x, if so, halt and answer YES.
  >   - Check  requires x's polynomial steps.

- ### *Def* NDA's Acception

  > - *A* is a NDA to problem Π
  > - When there **exists** an guess that make *A* answer YES, *A* accepts an instance I of Π.
  > - **Possibly**, on some execution of *A*, a YES answer will be given, *A* accepts an instance I of Π.
  > - // One time NOPE answer doesn't, mean unacception  for the existence of accepted guess not being falsified.

- ### *Def* Class NP (less informalized)

  > NP consists of thoes **decision problems** for which there **exists a NDA** that runs in polynomial time.

- ### *Prove* NP

  > - Method I (follows by informal def)
  >   1. Given an instance ***I*** of Π problem. 
  >   2. Given an claimed solution ***s*** to ***I***. 
  >   3. An **deterministic algorithm** can be contructed to **test** ***s*** is true in **polynomial time**.
  > - Method II (follows by less informal def)
  >   1. Given an instance ***I*** of Π problem. 
  >   2. An **NDA** can be contructed and runs in **polynomial time**.

- ### *Cmp* P&NP

  > - Class NP **⊆** Class P
  > - Problems in class P demands for a **polynomial time  deterministic algorithm to decide or solve**.
  > - Problems in class NP demands for a { **polynomial time  deterministic algorithm to check or verify**} || { **polynomial time NDA**} 



## 〇 The Class NPC

































