#import "@preview/polylux:0.3.1": *

#import themes.simple: *

#set text(
  size: 20pt,
  font: ("Noto Serif", "Noto Serif CJK SC"),
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
  == Let's Rewind...

  #v(-1em)

  Arcilator 是一个基于 CIRCT 的电路仿真综合器，工作原理是将硬件表示直接转换为 LLVM IR。

  $
  "FIRRTL / Verilog / ..." -> "HW Dialect" -> "LLVM IR" -> "Executable"
  $

  #pause

  在本项目开始前只支持单线程。本项目的目标是为其引入多线程支持。
]

#slide[
  == What's done

  #v(-1em)

  核心是将仿真逻辑进行划分。

  #list-one-by-one()[引入新的 IR 结构表示划分成的任务，以及任务之间的同步关系。][在后端将任务分裂为不同的“入口”，允许运行时进行调度。]

  #only("2-")[
    ```cpp
    void model_eval(model_storage_t *storage);
    ```
  ]

  #only("3-")[
    #line(length: 100%)
    ```cpp
    void model_eval_task_1(model_storage_t *storage);
    void model_eval_task_2(model_storage_t *storage);
    ```
  ]
]

#slide[
  == IR structure

  #v(-1em)

  引入了新的 IR 结构：

  ```llvm
  arc.task #bouba  { /* Do stuff... */ }
  arc.task #kiki   { /* Do stuff... */ }
  arc.task #foobar { /* Do stuff... */ }
  ```

  arc.task 遵从 PC 内存序，名字相同的 task 将会进行合并，并在过程中静态检查违例。

  #pause

  *arc.task 只有来自 arc.state_read 和 arc.state_write 的内存副作用！*
]

#centered-slide[
  #only("1")[
    $
      &"Semantic registers" \
      & -> #text([unallocated `arc.State`]) \
      & -> #text([allocated `arc.State`])\
      & -> "LLVM getelementptr"
    $
  ]
  #only("2")[
    $
      &"Semantic registers" \
      & -> #text(weight: "bold", [unallocated `arc.State`]) \
      & -> #text(weight: "bold", [allocated `arc.State`])\
      & -> "LLVM getelementptr"
    $
  ]
]

#slide[
  == State updates
  #v(-1em)
  \#7703 引入了新的状态下降方式：

  ```firrtl
  reg state : UInt<1>, clk
  state <= state_next
  ```
  #pause

  #line(length: 100%)

  ```cpp
  // Compute clk's value AFTER this eval
  // Compute state_next's value BEFORE this eval
  if(storage->old_clk != clk)
    storage->state = state_next;
  storage->old_clk = clk;
  ```
]

#slide[
  == State updates

  假设新状态计算及状态更新由同一线程完成，将状态更新过程分裂为两步：

  - 在原先的写入地点（`arc.state_write`），将新的状态值写入一个 Shadow register 中，仅本线程可见。
  - 在整个 eval 结尾插入一个新的 Task，将 Shadow register 中的值搬运回本来写入的位置。

  #pause

  后者称为 "Sync task"。
]

#centered-slide[
  #import "@preview/cetz:0.3.1"

  #cetz.canvas({
    import cetz.draw: *

    rect((-1, 0), (-5, -2), name: "leader")
    content("leader", "IO")

    rect((0, 0), (3, -2), name: "1")
    content("1", "1")
    rect((4, 0), (9, -2), name: "1_sync")
    content("1_sync", "1_sync")
    line("leader", "1", mark: (end: ">"))
    line("1", "1_sync", mark: (end: ">"))

    rect((0, -3), (3, -5), name: "2")
    content("2", "2")
    rect((4, -3), (9, -5), name: "2_sync")
    content("2_sync", "2_sync")
    line("2", "2_sync", mark: (end: ">"))

    rect((0, -6), (3, -8), name: "3")
    content("3", "3")
    rect((4, -6), (9, -8), name: "3_sync")
    content("3_sync", "3_sync")
    line("3", "3_sync", mark: (end: ">"))

    line((-0.5, 1), (-0.5, -9), stroke: (dash: "dashed"))
    line((3.5, 1), (3.5, -9), stroke: (dash: "dashed"))
    line((9.5, 1), (9.5, -9), stroke: (dash: "dashed"))
  })
]

#slide[
  == Partition planning 

  #list-one-by-one()[
    根据 SSA 爬出来状态之间的依赖关系，*按寄存器分配*
  ][
    METIS 一把梭
  ]
]

#slide[
  == Results

  Rocket 可以正确在多线程下执行，线程个数不定。

  - Baseline: 354540 Hz
  - 2-划分，并行执行: 294718 Hz
  - 2-划分，串行执行: 180212 Hz

  #pause

  CIRCT \#7650

]

#title-slide[
  == Thank you!

  #v(40pt)

  #image("./look.png", width: 120pt)
]
