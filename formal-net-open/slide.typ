#import "@preview/polylux:0.3.1": *

#import themes.simple: *

#show: simple-theme.with(
  footer: [],
)

#set text(
  font: ("Noto Serif", "Source Han Serif SC"),
)

#title-slide[
  = 开题报告 - 使用定理证明系统验证路由协议
  #v(-0.6em)
  === 计算机网络中的形式化方法与协议工程学

  #v(20pt)

  刘晓义 罗云千

  #v(40pt)

  #image("./float.png", width: 120pt)
]

#slide[
  == TL;DR
  #pause

#list-one-by-one(start: 2)[
  内嵌LTL模态逻辑到 Coq 中，定义路由协议 Specification
  - $tack.r square P$
][
  使用 Coq 给出一个实现，附带 Invariants，自动合成其余正确性的证明。
]
]

#slide[
  == Constructing the specification

  “消息传递模型”： 每个 Frame（时间点）对应一个传输事件：输入消息或者输出消息。

  #pause

  - 消息结构通过归纳数据类型定义
  - 引入一元谓词: $I(m)$, $O(m)$: 输入输出路由消息
  - 引入二元谓词: $R(a, n)$: 路由表

  #pause

  $
    I(...) -> R(...) U I(...)
  $
]

#slide[
  == Embedding

  为上述谓词添加一个“时刻”：

  $
    I(...) -> R(...) U I(...)
  $

  #pause

  $
    forall t_1, (
      I(t_1, i) -> \
      forall t_2 > t_1, (forall t_3 in (t_1, t_2), not I(t_3, ...)) -> R(t_2, ...)
    )
  $

  #pause

  - LTL Worlds $~ NN ~> t in NN$
  - 这一任务可以自动化进行
]

#slide[
  == Conformance proof: The easier part

  Wire-format $<=>$ 消息表示: 

  #pause

  问题：Illegal packets

  #pause

  Failable parser & handler: 给定 $t, m, not I(t, m)$ 可判定。

  ```coq
  Definition Parser : Set := Frame -> Result Message Error
  Definition Handler : Set :=
    State -> Message -> State × Option Error
  ```
]

#slide[
  == Conformance proof: The harder part

  状态机和路由表的性质

  #pause

  Invariant 手动给出，其他部分的 Weakest-precondition 是可判定的。

  Coq: `firstorder`: 尝试证明 $"WP" -> P$
]

#slide[
  == Expected things

  - 一个 Formal semantics
  - 一个正确的实现
  - (Optionally) 部分并行系统性质的证明 (e.g. 收敛性，正确性等)
]


#slide[
  == Alternatives

  LTL 自己存在一个证明系统，但是并不存在配套的定理证明工具。
]


#centered-slide[
  == Thank you!

  #image("./look.png", width: 120pt)
  #v(40pt)
]

// TODO: objdump plt with different libc
// TODO: fini from so