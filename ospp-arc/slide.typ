#import "@preview/polylux:0.3.1": *

#import themes.simple: *

#set text(
  size: 20pt,
  font: ("Noto Serif CJK SC"),
)

#set par(
  leading: 16pt
)

#show heading: it => [
  #set text(size: 32pt)
  #block(it.body)
]

#show: simple-theme.with(
  footer: [CIRCT 编译器的电路划分及 Arcilator 仿真并行化],
)

#title-slide[
  = CIRCT 编译器的电路划分及 Arcilator 仿真并行化

  #v(40pt)

  #image("./float.png", width: 120pt)
]

#slide[
  == Background

  传统的 EDA 工具链：

  $
  "Verilog/VHDL" &-> "Simulator" -> "Trace / Assertions / DPI Calls..." \
  &-> "Synthesis" -> "Netlist / Floorplan..."
  $

  问题：Verilog/VHDL 不是一个很“好”的电路描述语言：
  - 本质上是一个过程式语言
  - 可综合和不可综合的语言子集没有明显划分
]

#centered-slide[
  ```sv
  @always begin
    #1;
    a = 1;
    #1;
    a = 2;
  end
  ```
]

#slide[
  == Background

  一个更理想的以最终产生电路为目标的 HDL 语言：Chisel / FIRRTL：以寄存器和连线为

  $
  "State"_(n+1) <- f("State"_n)
  $

  目前 FIRRTL 的仿真综合后端是基于 MLIR 的 CIRCT 编译器。
]

#slide[
  == Background

  CIRCT 编译器表示提供了一种新的电路仿真方法：

  $
  "FIRRTL" -> "HW Dialect" -> "LLVM IR" -> "Executable"
  $
]

#centered-slide[
  #image("./overview.png")
]

#centered-slide[
  #image("./firrtl.png")
]

#slide[
  == Motivation
  目前 Arc 只支持单线程的仿真：

  - 缺乏多个线程之间状态的同步
  - 缺乏线程的创建和调度
  - #text(weight: "bold")[缺乏电路划分]

  当硬件规模增大，需要添加多线程支持。计算划分同时可以用于FPGA多片互联的自动综合。
]

#slide[
  == Motivation

  Verilator 仿真器的多线程支持：
  - Verilog 的仿真是 Task-based 的：每个 always 块，带有特定延迟的语句或者一个 task 块是一个 Task。
  - Task queue 动态调度
  - DPI 全局加锁，Trace 有部分多线程支持
]

#slide[
  == Motivation

  倾向于静态划分

  - Arcilator 所处理的电路表示不存在 Task
  - 目前不存在依赖分析，也就不存在事件触发的仿真
  - 静态划分可以大幅增加局部性
]

#slide[
  == Plan

  === 第一步：电路划分
  - 添加一级 LLVM Pass，在 Arc 之前对 CIRCT 核心方言构成的电路树进行划分
  - 对每个子电路分别经过 Arc 的 Lowering 过程
  - 直接将划分出的部分粘起来：创建跨分块通信所需的 Buffer
]

#slide[
  == Plan

  === 第二步：简单多线程支持
  - 添加线程的创建和销毁，Buffer 移动到全局
  - 添加同步

  这部分工作可以使用运行时实现
]

#slide[
  == Plan

  === 本项目目标：
  可以至少将 Rocket 规模的 FIRRTL，切分为至少两个线程并行执行，保证仿真的正确性

  暂时没有性能指标。
]

#slide[
  == Future work

  - 考虑如何和 DPI、Trace 协同工作
  - 考虑添加动态调度的可能性
]

#title-slide[
  == Thank you!

  #v(40pt)

  #image("./look.png", width: 120pt)
]
