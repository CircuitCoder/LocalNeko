#import "@preview/polylux:0.3.1": *
#import "@preview/cetz:0.3.1"

#import themes.simple: *

#show: simple-theme.with(
  footer: [ActiveN: A Scalable and Flexibly-programmable Event-driven Neuromorphic Processor],
)

#set text(
  size: 24pt
)

#title-slide[
  = ActiveN: A Scalable and Flexibly-programmable Event-driven Neuromorphic Processor

  #v(30pt)

  #text(weight: "bold")[Xiaoyi Liu]#super[1], Zhongzhu Pu#super[1], Peng Qu#super[1], Weimin Zheng#super[1], Youhui Zhang#super[1,2]

   #text(size: 0.7em)[
  #super[1] Beijing National Research Center for Information Science and Technology, Tsinghua University, China

  #super[2] Zhongguancun Laboratory, China
   ]
  #stack(
    dir: ltr,
    spacing: 20pt,
    image("craft.png", width: 60pt),
    image("tsinghua.png", width: 60pt)
  )
]

#slide[
  == Overview & Motivation

  Energy efficiency of neuromorphic computing comes from its event-driven nature.
  #pause
  - $=>$ Sparsity in both spatial and temporal domain

  #pause

  Trend 1: We're having more diverse neuron models (update model, postsynaptic accumulation model).

  - LIF and its variants, Izhikevich, HH, Biexponential

  #pause

  Conflict: Contemporary general-purpose processor architectures cannot efficiently deals with this sparsity.
]

#slide[
  == Overview & Motivation

  Energy efficiency of neuromorphic computing comes from its event-driven nature.
  - $=>$ Sparsity in both spatial and temporal domain

  Trend 2: We're having larger models.

  - Schmidt et al(2018): 4.13M neurons, 24.2B synapses

  #pause

  Conflict: High density storages (e.g. DRAMs) also cannot efficiently deals with sparsity.
]

#slide[
  == Overview & Motivation

  Energy efficiency of neuromorphic computing comes from its event-driven nature.
  - $=>$ Sparsity in both spatial and temporal domain

  Is it possible to introduce architectural / ISA extensions onto a general purpose architecture, to efficiently and performantly execute neuromorphic computing payloads?

  #pause

  YES #uncover("3-")[\*#super("Terms and conditions may apply")]

]

#slide[
  == Categorizing memory accesses
  #v(-1em)
  #cetz.canvas({
    import cetz.draw: *
    scale(3)
    rect((0, 0), (3+1/2, 2/3), name: "pre")
    rect((4, 0), (7+1/2, 2/3), name: "post")
    content("pre.center", [Presynaptic neuron])
    content("post.center", [Postsynaptic neurons(s)])
    line("pre.east", "post.west", mark: (end: ">"))

    content("pre.south", [PU], anchor: "north", padding: 0.2)
    content("post.south", [PU], anchor: "north", padding: 0.2)
  })

  #pause

  #v(-1em)

  #table(
    columns: (auto, auto, auto, auto),
    table.header(
      [Data], [Size], [Sparse Access?], [Lifetime]
    ),
    "Neuron state", $cal(O)(n)$, "Y/N", "Persistent",
    "Synapse data", $cal(O)(n^2)$, "Y", "Persistent",
    "Spikes", $cal(O)(n^2)$, "Y", "Temporary",
    "Neuron inputs", $cal(O)(n)$, "Y", "Persistent",
  )

  #v(-0.5em)

  #pause
  - Make synapse data accesses dense #only("4-")[$=>$ Store as CSR-format]
  - Eliminate spike data storage #only("5-")[$=>$ How to consume timely?]
  - Move neuron states / inputs into scratchpads #only("5-")[$=>$ How to write remotely?]
]

#slide[
  == Active messaging

  PUs can send messages to PUs. Incoming events would trigger event handlers, which is scheduled according to priorities by the hardware.

  #image("active-msg.png")
]

/*
#slide[
  == Unordered-ness of neuron updates / spike delivery

  - Neuron updates are invariant w.r.t. ordering of neurons
  - Spike delivery are invariant w.r.t. ordering of neurons and spikes
]
*/

#slide[
  == Access latencies for global memory (synapse matrix)

  Simple optimization: put CSR row pointers into scratchpad: saves one roundtrip.

  #pause

  Long latency accesses still unavoidable: requires blocking / MSHRs & registers.
]

#slide[
  == "Context-free" memory accesses

  Access to synapse connection matrix is "Context-free"

  ```js
  const neuronId;
  update(state[neuronId], input[t][neuronId]);
  const neighboors = await read(synapses[neuronId]);
  for(const [neighId, weight, delay] of neighboors)
    input[t+delay][neigh] += weight;
  ```
]

#slide[
  == "Context-free" memory accesses

  Access to synapse connection matrix is "Context-free"

  ```js
  // const neuronId;
  // update(state[neuronId], input[t][neuronId]);
  const neighboors; // = await read(synapses[neuronId]);
  for(const [neighId, weight, delay] of neighboors)
    input[t+delay][neigh] += weight;
  ```

  #pause

  "Fire-and-forget" asynchronous memory accesses
]

#slide[
  == Asynchronous memory access through Active Messaging

  PUs can send messages indicative of a load / store to memory controller.

  #only("1")[#image("async-mem.png")]
  #only("2-")[
    - More concurrent accesses $=>$ Higher achievable bandwidth
    - Saves on architectural "context tracking" structures: MSHRs, warp queue, physical registers... 
  ]

/*
  #only("3-")[
    If the model requires some context be retained, can still manually save into scratchpad.
  ]
*/
]

#slide[
  == CSR-aware memory controller

  Only for "context-free" synapse matrix loads: memory controller directly forwards the data to postsynaptic PU.

  #image("mem-fwd.png")
]

#slide[
  == Implementation / Core and active messaging
  Based on a in-order 3-stage RISC-V core.

  #image("core.png", width: 20em);
]

#slide[
  == Implementation / Core and active messaging
  #v(-2em)
  #image("core.png", width: 16em);
  - Base ISA RV32IF, 32-bit XLEN
  - Arguments are directly written into register file.
  - FPU 2-cycle delay, other FUs 1 cycle delay.
]

#slide[
  == Implementation / SMT-like event parallelism
  #v(-1em)
  FPU and branches introduces bubbles into the pipeline.
  SMT-like parallelism introduces \~25% performance gain.
  #v(-0.5em)
  #only("1")[#image("enhanced.png", width: 16em)]
  #only("2-")[
  #v(0.5em)
    Hardware cost:
    - Register file
    - PC register
    - #text(weight: "bold", "Issue width is not increased")
  ]
]

#slide[
  == Implementation / PPA
  #v(-1em)
  512 PU, interconnected with a two-layer ring bus. 

  Synthesised with 28nm process node. Frequency #text(weight: "bold")[1GHz].
  #v(-0.5em)
  #image("ppa.png", width: 20em)
]

#slide[
  == Evaluation / Performance & Energy efficiency
  #v(-1em)
  Booksim + DRAMsim + Core RTL model online co-simulation
  #v(-0.5em)

  #image("perf.png", width: 18em)

  - \~96.6x end-to-end performance against A100, \~151.9x energy efficiency.
  - Comparing with other neuromorphic processors, we don't have to store synapse data into on-die SRAM, meaning more computation power.
]

#slide[
  == Evaluation / Scalability

  #v(-1em)

  #columns(2,[
    #block[
      Same amount of neurons, scaling working PU count.

      - Can saturate computation and (most) memory bandwidth, depending on which is bounding.
      - Close to ideal scaling when computational-bounded.
    ]
    #image("scalability.png", height: 13em)
  ])


]

#slide[
  == Conclusion

  #v(-1.5em)

  ActiveN is a event-driven neuromorphic architecture, achieved by adding ISA extensions such as #text(weight: "bold")[active messanging, asynchronous memory access and CSR-aware memory controller] to a base RISC-V manycore architecture, which can be performant, efficient and flexible.

  #text(size: 0.7em)[
  #cetz.canvas({
    import cetz.draw: *
    scale(2)
    rect((0, 1), (2, 2/3 + 1), name: "0")
    rect((0, 0), (2, 2/3), name: "1")
    rect((5/2, 0), (9/2, 2/3), name: "2")
    rect((5, 0), (7+1/2, 2/3), name: "3")
    rect((0, -1), (3, 2/3 - 1), name: "4")
    content("0.center", [Base RV32IF])
    content("1.center", [Active Msg])
    content("2.center", [Async Mem])
    content("3.center", [CSR-aware Mem])
    content("4.center", [Neuron inputs in SP])
    line("0.south", "1.north", mark: (end: ">"))
    line("1.east", "2.west", mark: (end: ">"))
    line("2.east", "3.west", mark: (end: ">"))
    line("1.south", "4.north", mark: (end: ">"))
  })
  ]
]

#centered-slide[
  = Thank you!

  #v(20pt)

  #block[#align(left)[
  - GitHub: #text(font: "Source Code Pro")[CRAFT-THU/ActiveN]
  ]]
]
