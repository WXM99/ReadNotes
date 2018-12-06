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
         icode in {IPOPQ, IRET} : RRSP;
         1 : RNONE; // F means no reg
     ]
     
     int srcB = [
     	icode in {IRMMOVQ, IMRMOVQ, IOPQ} : rB;
         icode in {IPOPQ, IPUSH, ICALL, IRET} : RRSP;
         1 : RNONE;
     ]
     
     int dstM = [
         icode in {IMRMOVQ, IPOPQ} : rA;
         1 : RNONE;
     ]
         
     int dstE = [
     	icode in {IRRMOVQ} && Cnd : rB;
         icode in {IIRMOVQ, IOPQ} : rB;
         icode in {IPOPQ, IPUSHQ, ICALL, IRET} : RRSP;
         1 : RNONE;
     ]
     ```

  3. Execute

     ![execution](/Users/Miao/Desktop/execution.png)

     ``` c
     int aluA = [
     	icode in { IRRMOVQ, IOPQ } : valA;
     	icode in { IIRMOVQ, IRMMOVQ, IMRMOVQ } : valC;
     	icode in { ICALL, IPUSHQ } : -8;
     	icode in { IRET, IPOPQ } : 8;
     	# Other instructions don't need ALU
     ];
     
     int aluB = [
     	icode in { IRMMOVQ, IMRMOVQ, IOPQ, ICALL,
     			   IPUSHQ, IRET, IPOPQ } : valB;
     	icode in { IRRMOVQ, IIRMOVQ } : 0;
     	# Other instructions don't need ALU
     ];
     
     int alufun =[
         icode == IOPQ :ifun;
         1 : ALUADD;
     ];
     ```
