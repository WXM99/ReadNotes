# Chp6 Memory Hierarchy

> Program Locality:
>
> 程序趋于访问相同, 或是邻近的数据项集合

## 1. Storage techs

- RAM (Random access memory)

  - Dynamic: Cheap, Slower

    - be used as Main Memory plus 
      the frame buffer of a graphic system
    - Several hundreds of thousands of MB.
    - charging on a capacitor for each bit

  - Static:  Faster, expensive

    - be used as Cache Memory

    - On and Off CPU chip

    - No more than a few MB in DesktopSys

    - Bistable (双稳态) memory cell for each  bit

      |      | Transistor /bit | Access Time | Persistent | Sensitive | Cost  | Application         |
      | ---- | --------------- | ----------- | ---------- | --------- | ----- | ------------------- |
      | S    | 6               | 1×          | ✅          | ❌         | 1000× | Cache Mem           |
      | D    | 1               | 10×         | ❌          | ✅         | 1×    | Main Mem, frame Buf |

  - Conventional DRAMs

    - structure

      ![image-20190320205745736](./Chp6 Memory Hierarchy.assets/image-20190320205745736.png)

    - READ

      ![image-20190320205815334](./Chp6 Memory Hierarchy.assets/image-20190320205815334.png)

    - Memory Modules

      ![image-20190320212522259](./Chp6 Memory Hierarchy.assets/image-20190320212522259.png)

  - Enhanced DRAMs

    - FPM DRAMs (Fast Page Mode)

      faster when read SuperCells from the same line 

    - EDO DRAM (Extend Data Out DRAM)

      FPM DRAM to handle dense CAS

    - SDRAM (Synchronous DRAM)

      Faster

    - DDR SDRAM (Double Data-Rate Sychronous DRAM)

      SDRAM that can use two clocks as input signal to double the speed

      prefetch buffer (increase the effective bandwidth) size: 

      DDR (2 bits); DDR2 (4-bits); DDR3 (8 bits)

    - VRAM (Video RAM)

      Output whole line and move

      Parallel read and write

  - Nonvolatile Memory

    - Volatile: SRAMs and DRAMs will lose stored info when the suply voltage is turned off
    - ROM (Read-Only Memory): 
      - PROM (Programmable ROM): can be programmed only once;
      - EPROM: erasable PROM
      - flash memory
      - firmware: program stored in ROM

  - Accessing Main Memory

    ![image-20190321123044150](./Chp6 Memory Hierarchy.assets/image-20190321123044150.png)

    I/O bridge: 

    - North bridge: connect to main mem
    - South bridge: connect to IO devices

    Data load

    ![image-20190321133514570](./Chp6 Memory Hierarchy.assets/image-20190321133514570.png) 

- Disk

- SSD

## 2. Locality

- Temporary Locality

  对于同一个内存位置, 被某程序引用过一次, 则在和可能在不久的将来被多次引用

- Spatial Locaity

  程序趋于访问相同, 或是邻近的数据项集合

> Locality Principle应用在计算机系统的各个层次
>
> - 硬件级别中: cache memory
> - 操作系统中: main memory作为virtual memory的缓存
> - 应用程序中: web本地缓存

- 程序数据引用局部性
- 取指令的局部性

## 3. Storage Hierarchy

## 4. Cache Memory

> Early stage: 
>
> 1. register file in CPU 
> 2. DRAM main memory 
> 3. Disk memory

- Add SRAM L1

  Between REG and Main memory

  Access in 4 cycles

- Add 