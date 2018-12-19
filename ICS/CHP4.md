# **CHP4** Processer Architecture

  Def* **ISA** (Instruction-Set Architecture): 

​	A family of processer has an ISA
​	--Intel IA32Intel X86-4
​	--IBM/Freescale Power
​	--ARM

​	ISA connects compiler producer and precesser designer

## 〇 Y86-64 ISA

Def ISA(指令体系结构) includes：
​	-State Unit;
​	-Instruction Set:
​		--Code;
​		--Rules;
​	-Exceptions handling;

- ### Programmer visible statement	
  - Register × 15 (quad word -- 64bits):
    %rax, %rcx, %rdx, %rbx,
    %rsp, %rbp, 
    %rsi, %rdi, %r8, %r9, %r10, %r11, %r12, %r13, %r14
  - CC × 3:
    ZF, SF, OF
  - PC (Line)
  - Visual Memary (Array Model)
  - STAT: statement of the program
    SADR (非法地址),  SINS (非法指令),  SHLT (停机), SOK (正常)

- ### Y86-64 Instructions

  - movq ×4:
    - irmovq, rrmovq, mrmovq, rmmovq
    - 取地址格式：
      - Imm （绝对地址）
      - $imm(REG):  imm + REG (first index register)
      - 不支持第二及以上的变址寄存器
        × $imm(,reg1,$imm)
        × (,reg1,$imm)
        × (reg1,reg2)
  - OPq ×3（整数操作指令）:
    - addq subq andq xorq
    - OP指令会设置CC
  - jmp ×7:
    -  jmp jle jl je jne jge jg
  - crrmovq ×6:
    - cmovle cmovl cmove cmovne cmovge cmovg
  - call ret
  - popq (REG 为%rsp，以内存中的值为最终值，不进行栈顶的+8操作)
    pushq (REG为%rsp，先进行压栈操作，再将栈顶-8)
  - halt nop

- ### Instrutions Encode

  ![encode](/Users/Miao/Desktop/encode.png)

  - OPq


  - | addq |  60  | 0110 0000 |
    | :--: | :--: | :-------: |
    | subq |  61  | 0110 0001 |
    | andq |  62  | 0110 0010 |
    | xorq |  63  | 0110 0011 |

    jxx: jmp(70) to jg (76)

  - cmovq: rrmovq (20) to cmovg (26) 

  - %rax(0) o %r14(E)  %REG_NONE(F)

- ### Exception

  - AOK = 1 : Normal state
  - HLT = 2 : Halt
  - ADR = 3 : Memory address error (read and write)
  - INS = 4 : Invalid instruction

## 〇 Logic Design and HCL

- ### HCL

  - Gate: ```&&, ||, ! ``` 
    - Operation for a single bit
    - active

  - Combinational circuits to Boolean expression
    - Input of gates: 主输入，存出输出，其他门输出
    - 门的输出不可连接在一起，导致信号矛盾和非法电压
    - 无环

  - Diff: C logic exp and HCL 
    - HCL 的输入持续性影响输出(保持通讯), C logic exp只在程序执行时求值
    - C logic exp输入可以是整数（cast）， gate输入只有0、1
    - C logic exp可能会被短路径求值，HCL全响应

  - WORD (4-64bits) Opeation in HCL
    - word signle is claimed ```int``` without the size

    - cmp: ``` bool Eq = (A == B)``` A and B is word signal (int) with the same size.

    - case exp:

      ``` c
      word out = [
          select1 : expr1;
          select2 : expr2;
          ...
          selectk : exprk;
      ]
      ```

  - Set membership

    - ``` bool s = code in {SET} //code and elem in set are ints```

- ### Register and clock

  - 组合电路（逻辑电路）响应式发出（过程函数）
  - 时序电路（储存器）按位储存信号（变量）
  - 储存器分为：
    - Clock register : refresh by clock signal
      - PC, CC, Stat
    - Random access memory : visit by address and refresh in time
      - Visual memory
      - register file (%rax ~ %r14)


## 〇 SEQ Y86-64 Implemantation

Instruction set + Hardware = Processer (sequential)

- ### Stages:
  Divide processing

  - **Fetch**: 
    1. PC引导指令内存取值
    2. 解析为icode, ifun,(rA, rB, valC)
    3. icode引导计算（算数意义上）下一条指令地址valP = PC + len(INS)
  - **Decode**:
    1. rA, rB引导，在register file双端读口中读取valA，valB
    2. 有的指令(pop,push)不经过rA，rB引导，在regFile中读取%rsp
  - **Execute**:
    1. ifun引导ALU，对valA, valB进行计算
    2. 计算结果输出到valE (或为内存地址，栈指针移动，计算结果，0+原值)
    3. 根据valE(op)设置CC
    4. 条件指令（cmov，jxx）读取CC决定是否更新可见状态
  - **Memory**:
    - 数据写入内存
    - 读取内存数据到valM
  - **Write Back**:
    - 双端口写入数据到regFile，更新两个寄存器

  - **PC Upate**:
    - 将PC设置为（逻辑上）下一条指令的地址

- ### Instructions fitting:

  - **Class 1** 单一寄存器访问类： Opq, rrmovq, irmovq:

    - Fetch 时正常取指令并解码(icode, ifun, rA, rB, //valC)，更新valP(+2,+2,+10)

    - Decode 非F则更新valA (valB)

    - OPq由ifun计算得出valE（**valB op valA的顺序**），rrm和irm取0+valA/valC

    - Memory 空置

    - Write Back 写入valE到rB

    - PC update 写入valP到PC

      ![class1](/Users/Miao/Desktop/class1.png)

  - **Class 2:** 内存访问类：rmmovq, mrmovq

    - E stage：有效地址由ALU的输出valE给出，即valB + valC

    - M stage：valE作为地址，写入valA或读出到valM

      ![class2](/Users/Miao/Desktop/class2.png)

  - **Class 3**: 栈操作： pushq, popq

    - 访问内存 并且 修改寄存器%rs（rA)

      ![class3](/Users/Miao/Desktop/class3.png)

  - Class 4: 控制转移：jxx, call, ret

    - CC和ifun引导产生一个一位信号Cnd，标志着taken (valP as PC) or not (valC as PC).

    - ret和popq类似，但在Update PC阶段设置PC为valM (return addr)

      ![class4](/Users/Miao/Desktop/class4.png)

    ![c4cmoq](/Users/Miao/Desktop/c4cmoq.png)

- ### SEQ Hardware Structure

  ![hardware](/Users/Miao/Desktop/hardware.png)

- ### SEQ Timing

  - CLOCK Control **PC, CC, Memory, RegFile**
  - 组合逻辑在一个Cycle内完成并稳定在4个Clock寄存机入口
  - 下一个时钟周期上升时，组合逻辑写入寄存器
  - 下一个Cycle内寄存器持续输出数据，组合逻辑进行处理

- ### SEQ Phase Realization

  1. Fetch：

     ![fetch](/Users/Miao/Desktop/fetch.png)

     ```c
     bool instr_valid = icode in {@ALL_IS};
     bool need_regids = icode in {IRRMOVQ, IIRMOVQ, IRMMOVQ, 
                                  IMRMOVQ, IOPQ, IPUSHQ, IPOPQ};
     bool need_valC = icode in {IIRMOVQ,IRMOVQ, IMRMOVQ, IJXX, ICALL};
     ```

  2. Decode and Write Back:

     ![decode](/Users/Miao/Desktop/decode.png)

     ```C
     int srcA = [
         icode in {IRRMOVQ, IRMMOVQ, IOPQ, IPUSHQ} : rA;
         icode in {IPOPQ, IRET}                    : RRSP;
         1                                         : RNONE; // F means no reg
     ]
     
     int srcB = [
     	icode in {IRMMOVQ, IMRMOVQ, IOPQ}    : rB;
         icode in {IPOPQ, IPUSH, ICALL, IRET} : RRSP;
         1                                    : RNONE;
     ]
     
     int dstM = [
         icode in {IMRMOVQ, IPOPQ} : rA;
         1                         : RNONE;
     ]
         
     int dstE = [
     	icode in {IRRMOVQ} && Cnd             : rB;
         icode in {IIRMOVQ, IOPQ}              : rB;
         icode in {IPOPQ, IPUSHQ, ICALL, IRET} : RRSP;
         1                                     : RNONE;
     ]
     ```

  3. Execute

     ![execution](/Users/Miao/Desktop/execution.png)

     ``` c
     int aluA = [
     	icode in { IRRMOVQ, IOPQ }             : valA;
     	icode in { IIRMOVQ, IRMMOVQ, IMRMOVQ } : valC;
     	icode in { ICALL, IPUSHQ }             : -8;
     	icode in { IRET, IPOPQ }               : 8;
     	# Other instructions don't need ALU
     ];
     
     int aluB = [
     	icode in { IRMMOVQ, IMRMOVQ, IOPQ, ICALL,
     			   IPUSHQ, IRET, IPOPQ }         : valB;
     	icode in { IRRMOVQ, IIRMOVQ }            : 0;
     	# Other instructions don't need ALU
     ];
     
     int alufun =[
         icode == IOPQ :ifun;
         1             : ALUADD;   //pushq popq call ret movq...
     ];
     
     bool SetCC = icode == IOPQ;
     ```

  4. Memory

     ![memory](/Users/Miao/Desktop/memory.png)

     ```c
     int mem_addr =[
     	icode in {IRMMOVQ, IPUSHQ, ICALL, IMRMOVQ } : valE;
     	icode in {IPOPQ, IRET }                     : valA;
     	# Other instructions don't need address
     ];
     
     int mem_data =[
     	# Value from register
     	icode in {IRMMOVQ, IPUSHQ } : valA;
     	# Return PC
     	icode == ICALL              : valP ;
     	# Default: Don't write anything
     ];
     
     int Stat = [
     	imem_ error || dmem_ error : SADR;
     	! instr_valid              : SINS;
     	icode == IHALT             : SHLT ;
     	1                          : SAOK;
     ];
     
     bool mem_read = icode in {IMRMOVQ, IPOPQ, IRET};
     bool mem_write = icode in {IRMMOVQ, IPUSHQ, ICALL};
     ```

  5. Update PC

     ![updatepc](/Users/Miao/Desktop/updatepc.png)

     ```c
     word new_ pc =[
     	# Call. Use instruction constant
     	icode == ICALL       : valC;
     	# Taken branch. Use instruction constant
     	icode == IJXX && Cnd : valC;
     	# Completion of RET instruction. Use value from stack
     	icode == IRET        : valM;
     	# Default: Use incremented PC
     	1                    : valP;
     ];
     ```



## 〇 Y86-64 Pipeline

- ### SEQ+ model: Rearrange  stages

  ![pcad](/Users/Miao/Desktop/pcad.png)

  - 总线信号分别存储在寄存器中
  - 下一个Cycle伊始，总线信号通过PC逻辑电路产生newPC信号
  - PC信号没有寄存器，为动态信号

- ### PIPE- model: 

  ![pipe-](/Users/Miao/Desktop/pipe-.png)

  - Pipeline register  (down to up)
    - F: 保存PC的预测值
    - D: 保存最新指令编码的解析信息
    - E: 译码指令信息和RegFile读取的信息 
    - M: 储存ALU计算结果和条件转移的分支条件和目标
    - W: 储存提供给RegFile和PCselect的数据
  - Next PC
    - Normal ins: valP = last_PC + sizeof(last_INS) 
    - IJXX: *Branch Prediction*
      - Taken: valC (Y86-64: always taken)
      - Not taken: valP
    - ICALL: valC
    - IRET: M(R[%rsp]) No prediction, just pause
    - Select PC选择 **[** predPC(normal), M_valA(not taken jxx's valP), W_valM(ret) **]**

- ### PIPE model: Hazard

  - Instruction Related:

    - Data related:
      下一条指令用到这一条指令的计算结果
    - Control related:
      这一条指令确定下一条指令的位置 (jxx, call, ret)
      算数意义上的下一条指令地址(valP)和实际有可能不同

  - Hazard: 指令相关可能会导致的流水线计算错误

    - Data hazard:

      e.g.

      ```assembly
      # /*under PIPE-model Y86-64 program1*/
      irmovq $10, %rdx  # inst1 in F （Data goes in reg in WriteBack stage）
      irmovq  $3, %rax  # inst2 in F; inst1 in D  
      nop               # inst2 in D; inst1 in E
      nop               # inst2 in E; inst1 in M
      addq %rdx, %rax   # when Decode this ins (this ins in Fetch)
                        # inst1 has been finished 
                        # yet inst2 is in WB(not finishend yet)
      ```

      过程program1输出%rax=10，与预期13不符合，在Cycle6 addq指令decode时，inst2还未能将3写回%rax，此时取值为%rax=0，导致alu输出valE = 0 + R[%rdx] = 10。addq指令在Cycle9 写回10到%rax 结束。

      - PIPE- 指令中取值的寄存器在其之前的三条指令被修改，则会出现DataHazard
        （D与W相差3cycles）

      - 内存读取值指令紧接着内存修改指令不会出现Hazard(各自的M阶段恰好相差1Cycle)

    - Control hazard:

      - 

    - Types

      > 1. RegisterFile的读写在不同Stage  **//!**
      > 2. PC和PCupdate的冲突导致Fetch阶段的Control Hazard  **//!**
      > 3. 指令内存的写入(M)和地址读取(F)的冲突，一般认为DM和IM隔离，不发生冲突
      > 4. CC在OPQ指令E阶段写入，读取CC的CMOVQ在E阶段读取，JXX在M阶段读取(均在OPQ的E或之后，不会发生冲突)
      > 5. Stat分别于每条指令关联，Exception按序停止 **//!**

    - Handle

      1. Stalling：// DataHazard

         让读取RegFile的指令停留在Decode阶段，直到修改reg的指令通过WB阶段；之前的指令stall在Fetch，通过不修改PC实现

         插入Bubble由逻辑电路控制

      2. Data Forwarding

         - regFile的会入写在PIPE-中直到WB才能完成，PIPE中的forwarding将需要写入的值率先传递到就存起E寄存器中，作为操作输入(W_valE M_valE **e_valE**)，避免暂停（Reg forwarding）

           ```c
           W_valE --> E_valA(E_valB) // 3 cycles ahead /WD valE
           W_valM --> E_valA(E_valB) // 3 cycles ahead /WD valM
           M_valE --> E_valA(E_valB) // 2  /MD Hazard/
           m_valm --> E_valA(E_valB) // (2+)=2 /plus means stage中获取 Load-use Hazard
           e_vale --> E_valA(E_valB) // (1+)=1 /ED Hazard
           ```

           ![forwarding](/Users/Miao/Desktop/forwarding.png)

           > - PIPE模型，用Forwarding处理DataHazard
           >
           > - 组合逻辑`Sel+FwdA`集合了PIPE-中的`SelectA`和Forwarding取值的逻辑
           >   - 其出口d_valA = E_valA 可能为 D_valP, R[rA], forwardingDatas 
           >
           > - 组合逻辑`FwdB`完成valB的Forwarding取值逻辑

         - Decode阶段，逻辑电路决定E_valA/B使用RegFile读取值还是Forwarding的值和Forwarding值的优先关系

      3. Load/Use Hazard

         -  Load转置从Memory读取值到寄存器

         - 上一条指令A load过后，本条指B令再读取相同寄存器。由于A中最早只能在M阶段后产生正确值，而B在Decode阶段就需要取值，超前A‘sM一个Cycle，故Forwarding无法解决

         - Handle：

           - stalling+dataForwarding

             Load指令在E阶段时，PIPE控制逻辑检测到此时D阶段指令需要使用Load的值，则在下一个Cycle中的E阶段插入Bubble。

             下一个周期时，use指令依然在D阶段，load指令不受Bubble影响到达M阶段；该Cycle中后期m_valM Forwarding回到use指令D阶段使用

             ![loaduse](/Users/Miao/Desktop/loaduse.png)

             - Load interlock: 在use指令的D阶段时E中插入Bubble，拉长CPI到2，降低吞吐量

      4. Avoid Controll Hazard

         ret和 jxx(和任何其他)指令在Fetch阶段需要根据当前指令信息和PC，经过F阶段的逻辑电路来将预测的下一条指令地址写入F寄存器的predPC。

         下一个Cycle内predPC经过选择后到达指令内存取值，并再次完成PU和填充Dp_reg

         - 对于RET：
           在Decode阶段连续插入**向前**插入三个Bubble，到达WB阶段后，以W_valM为值更新PC(也可取用m_valM, 但是会拉长时钟周期)

         - Mispredicted Branch：
           进入流水线的分支下的指令最多为两条(不包括JXX)
           jxx前的运算会在E阶段完成后的M_Cnd判断是否预测正确

           - 若正确(Cnd == 1)则不做修改，按序执行，没有Cycle浪费(等价于顺序执行)

           - 若预测错误，则在**下个周期**内向D和E插入Bubbles，分别抹去两条错误指令在D和F阶段（错误指令2在F被正确指令覆盖，错误指令1在D被指令2的Bubble覆盖）；
             同时取回JXX指令的valP (JXX在该周期内完成E阶段，valP在M_valA取得)作为下一条指令的地址（正确地址进入Fetch阶段）
             该周期内的流水线状态

             | Fetch     | Decode        | Execute       | Memory |
             | --------- | ------------- | ------------- | ------ |
             | 错误指令2 | 错误指令1     | JXX           |        |
             | 正确指令  | 指令2的Bubble | 指令1的Bubble | JXX    |

             再下一个Cycle变为正确指令正常执行，复写掉错误指令，浪费两个Cycle

- ### PIPE stages detail

  1. **PCselect & Fetch**

     ![pfetch](/Users/Miao/Desktop/pfetch.png)

     ```c
     bool f_instr_valid = icode in {@ALL_IS};
     bool f_need_regids = icode in {IRRMOVQ, IIRMOVQ, IRMMOVQ, 
                                  IMRMOVQ, IOPQ, IPUSHQ, IPOPQ};
     bool f_need_valC = icode in {IIRMOVQ,IRMOVQ, IMRMOVQ, IJXX, ICALL};
     
     int f_pc = [
     	// Mispredicted branch. Fetch at incremented PC
     	M_icode == IJXX && !M_Cnd  : M_valA;
     	// Completion of RET instruction
     	W_icode == IRET            : W_valM;
     	// Default: Use predicted value of PC
     	1                          : F_predPC; 
     ];
     
     int f_predPC = [
         f_icode in {IJXX, ICALL}  : f_valC;
         // Default: Use data from PC increment
         1:                        : f_valP;
     ]
     ```

  2. **Decode &WriteBack**

     ![pDecodeWB](/Users/Miao/Desktop/pDecodeWB.png)

     ```c
     int d_dstE = [
         D_ icode in {IRRMOVQ, IIRMOVQ, IOPQ}      : D_rB;
     	D_ icode in {IPUSHQ, IPOPQ, ICALL, IRET } : RRSP;
         1                                         : RNONE; 
     ]
         
     int d_dstM = [
     	D_icode in {IMRMOVQ, IPOPQ} : D_rA;
         1                           : RNONE;
     ] 
     
     int d_srcA = [
     	D_icode in {IOPQ, IRRMOVQ, IRMMOVQ, IPUSHQ} : D_rA;
         D_icode in {IPOPQ, IRET}                    : RRSP;
         1                                           : RNONE;    
     ]
        
     int d_srcB = [
         D_icode in {IOPQ, IRRMOVQ, IRMMOVQ }        : D_rB;
         D_icode in {IPOPQ, IPUSH, ICALL, IRET}      : RRSP;
         1                                           : RNONE;    
     ]
         
     int d_valA = [ //优先级排序
     	D_icode in {ICALL, IJXX} : D_valP; // Use incremented PC
     	d_srcA == e_dstE         : e_valE; // Forward valE from execute
         d_srcA == M_dstM         : *m*_valM; // Forward valM from memory
     	d_srcA == M_dstE 	     : M_valE; // Forward valE from memory
     	d_srcA == W_dstM 		 : W_valM; // Forward valM from write back
     	d_srcA == W_dstE 		 : W_valE; // Forward valE from write back
     	1                        : d_rvalA;// Use value read from register file
     ];
     // d_valA中的优先级为，valP选择级别最高，Forwarding距离由短到长(距离近的指令后进入流水线，状态最新)
     
     int d_valB = [
         d_srcB == e_dstE : e_valE;  // Forward valE from execute
     	d_srcB == M_dstM : m_valM;  // Forward valM from memory .
         d_srcB == M_dstE : M_valE;  // Forward valE from memory
     	d_srcB == W_dstM : W_valM;  // Forward valM from write back
         d_srcB == W_dstE : W_valE;  // Forward valE from write back
     	1                : d_rvalB; // Use value read from register file
     ]
     ```

  3. Execute

     ![pexecute](/Users/Miao/Desktop/pexecute.png)

     ```c
     int aluA =[
     	E_icode in { IRRMOVQ, IOPQ }             : E_valA;
     	E_icode in { IIRMOVQ, IRMMOVQ, IMRMOVQ } : E_valC;
     	E_icode in { ICALL, IPUSHQ }             : -8;
     	E_icode in { IRET, IPOPQ }               : 8;
     	# Other instructions don' t need ALU
     ];
     
     int aluB = [
     	E_ icode in { IRMMOVQ, IMRMOVQ, IOPQ, 
                       ICALL, IPUSHQ, IRET, IPOPQ } : E_ _valB;
     	E_ icode in { IRRMOVQ, IIRMOVQ }           : 0;
         # Other instructions don' t need ALU
     ];
     
     int alufun = [
         E_icode == IOPQ : E_ifun;
         1               : ALUADD;
     ]
         
     int e_valE = aluB _OP_ aluA;
     int e_valA = E_valA;
     int e_dstE = [
         (E_icode == IRRMOVQ) && !e_Cnd : RNONE; // Do not write back
         1                              : E_dstE;
     ];
     
     /* HCL of  setCC and e_cond is in Pipeline controll logic */
     ```

  4. Memory

     ![pmem](/Users/Miao/Desktop/pmem.png)

     ```c
     int mem_addr = [
         M_icode in { IRMMOVQ, IPUSHQ, ICALL, IMRMOVQ} : M_valE;
         M_icode in { IPOPQ, IRET}                     : M_valA;
         # Other instructions don't need addr
     ];
     
     bool mem_read = M_icode in {IMRMOVQ, IPOPQ, IRET};
     bool mem_write = M_icode in {IRMMOVQ, IPUSHQ, ICALL};
     ```

- ### Pipeline Controll Logic

  - Cases
    1. Load/Use Hazard
    2. Stall 3 cycles for ret
    3. Mispredicted branch handle
    4. Exception handle

  - 特殊控制处理

    - Load指令类：内存取值的指令类：MRMOVQ 和 POPQ

      Use指令：Decode阶段读取RegFile的指令类

      当Use指令位于Decode 且 Load 指令位于Exe时为Load/use Hazard (1Cycle ahead)

      - Handle：

        Use指令阻滞在Decode阶段，并在E**插入Bubble**：

        | Decode | Execute | Memor |
        | ------ | ------- | ----- |
        | Use    | Load    | \     |
        | Use    | Bubble  | Load  |

        > 阻滞Use在D：D的PIPE寄存器在时钟下降沿不写入，保持固定；同时保证F的PIPE寄存器固定；流水线在D和F进制，没有吞量
        >
        > E阶段插入Bubble：E寄存器的icode用0x0代替（用nop指令填补）

    - RET指令

      RET指令完成M阶段前，下一条指令时钟组织在F，直到被正确地址覆盖，延迟3个cycle

      | Fetch    | Decode | Execute | Memory |
      | -------- | ------ | ------- | ------ |
      | ret      | \      | \       | \      |
      | ret_next | ret    | \       | \      |
      | ret_next | Bubble | ret     | \      |
      | ret_next | Bubble | nop     | ret    |
      | re_addr  | Bubble | nop     | nop    |

    - Mispredicted Branch

      - 进入流水线的分支下的指令最多为两条(不包括JXX)
        jxx前的运算会在E阶段完成后的M_Cnd判断是否预测正确

        - 若正确(Cnd == 1)则不做修改，按序执行，没有Cycle浪费(等价于顺序执行)

        - 若预测错误，则在**下个周期**内向D和E插入Bubbles，分别抹去两条错误指令在D和F阶段（错误指令2在F被正确指令覆盖，错误指令1在D被指令2的Bubble覆盖）；
          同时取回JXX指令的valP (JXX在该周期内完成E阶段，valP在M_valA取得)作为下一条指令的地址（正确地址进入Fetch阶段）
          该周期内的流水线状态

          | Fetch     | Decode        | Execute       | Memory |
          | --------- | ------------- | ------------- | ------ |
          | 错误指令2 | 错误指令1     | JXX           |        |
          | 正确指令  | 指令2被Bubble | 指令1被Bubble | JXX    |

          再下一个Cycle变为正确指令正常执行，复写掉错误指令，浪费两个Cycle

    - // Exception的处理

  - 发现特殊控制的条件

    - 通过d_srcA和d_srcB获取Decode中指令的寄存器ID

    - 通过流水线寄存器DEM获取stages中的指令状态

      - ret指令检查icode

      - load/use指令组合检查e_icode(为Load类)和d_src(Use load中的汇)

      - Mispredicted branch时在JXX指令到达M寄存器时即可发现并纠正(M_valP)

      - JXX位于E阶段时，e_Cnd可以说明是否跳转

      - 检查M阶段中的stat和W中的stat发现异常指令，阻止状态修改

        | case                | trigger Cnd                                               |
        | ------------------- | --------------------------------------------------------- |
        | ret                 | IRET in {D_icode,  E_code, M_icode}                       |
        | Load/Use Hazard     | E_icode in (IMRMOVQ, IPOPQ) && E_dstM in {d_srcA, d_srcB} |
        | Mispredicted branch | E_icode == IJXX && !e_Cnd                                 |
        | Exception           | m_stat != SOK \|\| W_stat != SOK                          |

  - 流水线控制机制  

    - 流水线寄存器有两个控制输入：Stall and Bubble 决定时钟上升沿寄存器如何更新

      - Stall = Bubble = 0: 正常更新为输入

      - Stall = 1； Bubble = 0：流水线寄存器禁止更新，保持固定

      - Bubble = 1；Stall = 0：流水线寄存器复位(不同阶段不一样，改变icode，srcAB等)，等价于变为nop指令

      - Bubble = Stall = 1：不允许             

        | Stall | Bubble | Input | State | Output(LC) | state(NC) | Output(NC) |
        | ----- | ------ | ----- | ----- | ---------- | --------- | ---------- |
        | 0     | 0      | y     | x     | x          | y         | y          |
        | 1     | 0      | y     | x     | x          | x         | x          |
        | 0     | 1      | y     | x     | x          | nop       | nop        |
        | 1     | 1      | y     | x     | x          | U(X\|Y)   | U(X\|Y)    |

    - 流水线控制组合逻辑电路利用Bubble，Stall，Normal的组合对特殊情况进行控制

    - 控制输出必须保证在一个Cycle内完成，来明确下个周期寄存器的读写权限

    - 控制逻辑对不同情况的处理方式

      | Condition    | F (PipeReg) | D(PipeReg) | E(PipeReg) | M(PipeReg) | W(PipeReg) |
      | ------------ | ----------- | ---------- | ---------- | ---------- | ---------- |
      | ret          | Stall       | Bubble     | Normal     | Normal     | Normal     |
      | Load/Use     | Stall       | Stall      | Bubble     | Normal     | Normal     |
      | Mispredicted | Normal      | Bubble     | Bubble     | Normal     | Normal     |

  - 控制条件的组合 

    特殊处理的状态枚举

    |                                    | Decode | Execute | Memory |
    | ---------------------------------- | ------ | ------- | ------ |
    | Load/Use                #          | Use    | Load    | \      |
    | Mispredicted branch *              | \      | JXX     | \      |
    | ret(1)                        #  * | ret    | \       | \      |
    | ret(2)                             | Bubble | ret     | \      |
    | ret(3)                             | Bubble | Bubble  | ret    |

    互斥操作组合：

    1. E: JXX + D:ret (*match)

       - Jmp taken到ret指令，但实际为预测错误，要求消除ret的错误指令

         | CND            | F      | D      | E      | M      | W      |
         | -------------- | ------ | ------ | ------ | ------ | ------ |
         | **Mispredict** | Normal | Bubble | Bubble | Normal | Normal |
         | **ret**        | Stall  | Bubble | Normal | Normal | Normal |
         | **Combine**    | Stall  | Bubble | Bubble | Normal | Normal |

       - 处理方式依旧按照Mispredict Branch, ret不作处理依然会被MB的Bubble抹除

    2. E: loadRSP + D:ret(useRSP) (#match) 

       - Load指令类修改了%rsp，到达Estage； ret指令读取%rsp，位于Dstage

         | CND          | F     | D      | E      | M      | W      |
         | ------------ | ----- | ------ | ------ | ------ | ------ |
         | **Load/Use** | Stall | Stall  | Bubble | Normal | Normal |
         | **ret**      | Stall | Bubble | Normal | Normal | Normal |
         | **Combine**  | Stall | Stall  | Bubble | Normal | Normal |

       - 先保证Load/use的争取执行，ret到正确的返回地址；下一个周期内ret依然位于D，再按照ret规则处理

  - 控制逻辑的实现

    产生各个刘淑娴寄存器的Bubble和Stall信号

  ![pipeLogic](/Users/Miao/Desktop/pipeLogic.png)

  ```C
  bool F_bubble = 0;
  
  bool F_stall =
  	/* LU: Conditions for a load/use hazard */
  	E_icode in { IMRMOVQ, IPOPQ } &&    // Load inst
  	E_dstM  in { d_srcA, d_srcB }       // used reg in next ins
  	||    
  	/* RET: Stalling at fetch while ret passes through pipeline for 3 cycles */
  	IRET in { D_icode, E_icode, M_icode } ;
  
  bool D_stall =
  	/* LU: Conditions for a load/use hazard */
  	E_icode in { IMRMOVQ, IPOPQ } &&
  	E_dstM  in { d_srcA, d_srcB } ;
  
  bool D_bubble =
  	/* Mispredicted branch */
  	(E_icode == IJXX && !e_Cnd)
  	||
  	/* RET: Stalling at fetch while ret passes through pipeline */
      IRET in { D_icode, E_icode, M_icode } && 
      /* Not load/use and ret combine, just ret */
      !(E_icode in { IMRMOVQ, IPOPQ } && E_dstM in { d_srcA, d_srcB })
  
  bool E_stall = 0;
  
  bool E_bubble =
  	/* Mispredicted branch */
  	(E_icode == IJXX && !e_Cnd)
      ||
  	/* LU: Conditions for a load/use */
  	E_icode in { IMRMOVQ, IPOPQ } && // load
  	E_dstM in { d_srcA, d_srcB};     // use
  
  bool M_stall = 0;
  /* Start injecting bubbles as soon as exception passes through memory stage */
  bool M_bubble = m_stat in { SADR, SINS, SHLT } || W_stat in { SADR, SINS, SHLT };
  
  bool W_stall = W_stat in { SADR, SINS, SHLT };
  bool W_bubble = 0;
  ```

- ### Exception

  异常指令之前的指令都被执行完成，之后的指令不修改可见态

  1. HALT
  2. Invalid Instruction code
  3. Invalid Memory Address

  - 多条指令引起的异常：流水线深处指令优先级最高
  - 错误分支下执行的异常指令
    - 错误指令被流水线控制逻辑取消
  - 异常指令之后的指令改变了可见态
    - 每个流水线寄存器包括状态字段stat，stat与异常指令一同流水线内传播，直到到达W阶段，发现异常并停机
    - M和W阶段有异常抛出时，流水线控制逻辑禁止更新CC和内存