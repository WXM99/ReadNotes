# CHP10 P-NP-NPC

- Decision problem（判定问题）: ret YES or NOPE
- Optimization problem（优化问题）: the minimization or maximum in a list of element
- D&O could be modified reciprocally



## 〇 The Class P

- ### *Def* Deterministic Algorithm （确定性算法）

  > - Algorithm A can sovle proble Π. 
  > - Presented with an instance of the problem Π, A has **only** **one choice in each step** throughout its execution.
  > - A is run again and again on the same Π, **output never change**.
  > - **A is a Deterministic Algorithm**

- ### *Def* **Class of Decision Problems P** (polynomial) （判定P问题）

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
    >   if G is **bipartite**
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

