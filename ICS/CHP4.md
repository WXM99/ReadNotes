# CHP4 Processer Architecture

  Def* **ISA** (Instruction-Set Architecture): 

​	A family of processer has an ISA
​	--Intel IA32Intel X86-4
​	--IBM/Freescale Power
​	--ARM

​	ISA connects compiler producer and precesser designer

## ○Y86-64 ISA

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

## ○Logic Design and HCL

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


## ○SEQ Y86-64 Implemantation

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



## ○Y86-64 Pipeline

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

      2. Data Forwarding

- ### PIPE stages detail

- ### Pipeline Controll Logic

- 