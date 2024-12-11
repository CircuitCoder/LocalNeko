#import "@preview/polylux:0.3.1": *

#import themes.simple: *

#set text(
  size: 20pt,
  font: ("Noto Serif"),
)

#set par(
  leading: 16pt
)

#show heading: it => [
  #set text(size: 32pt)
  #block(it.body)
]

#show: simple-theme.with(
  footer: [论文研讨 - Lightyear: Using Modularity to Scale BGP Control Plane Verification],
)

#let ly = smallcaps[Lightyear];

#title-slide[
  = 论文研讨 - #ly: Using Modularity to Scale BGP Control Plane Verification

  #v(1em)

  #text(size: 0.6em)[
    Alan Tang  #super[1],  Ryan Beckett  #super[2],  Steven Benaloh  #super[2],  Karthick Jayaraman  #super[2],  Tejas Patil  #super[2],  Todd Millstein  #super[1],  George Varghese  #super[1],

    #super[1] UCLA, #super[2] Microsoft
  ]
]
#slide[
  == Pre-Background...

  Properties, repersented by *propositions and predicates*, are syntatical objects.

  #only(1)[
  $
    forall r, s in QQ, r = s or exists t in QQ, r < t < s
  $
  ]

  #pause

  $
    "Precondition (Assumptions)" => "Postconditions (Assetions)"
  $

  #pause

  Two way of reasoning about their correctness:
  #list-one-by-one(start:3)[Formal deduction][*Model checking*]
]

#slide[
  == Background

  A lot of desirable properties are *global*:
  - When *all nodes* works, no incorrect routes are advertised.
  - When *all edges* works, *all nodes* acknowledge correct routes.

  #pause

  Verifying global properties *globally* is HARD.
  - Symbolically: Amount of states grows exponentially, amount of checks grows (at least) quadratically.
  - Runtime: Synchronization is costly / hard to do right.
]

#slide[

  It's much easier to do *local checks*.
  #v(-1em)
  #pause

  == #ly
  #v(-1em)
  #pause

  Given:
  - Configuration (Topology and policies)
  - Local invariants
  - Desirable global properties

  Generates:
  - Local checks
  - Proof that local constraints imply global properties
]

#slide[
  == The language of #ly

  #v(-1em)

  Basically the quantifier-free fragment of FOL, specifing behaviors at *locations* (nodes or edges).

  #pause

  E.g.  At node $N$:
  $
    "addr"(r) in "dead:beef::/64"
  $

  #pause

  Generated functions: `Import, Export, Originates`
  - `Import: ` `Edge` $times$ `Route` $->$ `Route` $union {$ `Reject` $}$ 
]

#slide[
  == An example...

  #v(-2em)

  #grid(columns: (60%, 40%), [
    #align(center)[
      #image("./topo.png", height: 12em)
    ]
  ], [
    #pause
    *Safety*:

    No routes from ISP1 reaches ISP2

    #pause

    *Liveness*

    Routes from customer reaches ISP2
  ])
]

#slide[
  == An example...

  #v(-2em)

  #grid(columns: (60%, 40%), [
    #align(center)[
      #image("./topo.png", height: 12em)
    ]
  ], [
    *Property*: At R2 $->$ ISP2

    $not "FromISP1"(r)$

    *Constraints*: At all internal edges:

    $"FromISP1"(r) \ -> 100:1 in "Comm"(r)$
  ])
]

#slide[
  == Scope of #ly

  #v(-1.5em)

  Traditionally, predicates are *indexed by time*, or reasoning is done in *temporal logic*.

  #pause

  #ly does not use temporal information. We only care about:
  - Safety: No bogus routes
  - Liveness: Valid routes will be broadcasted
  #v(-0.5em)

#align(center)[
  $diamond diamond A -> diamond A$
]
  #pause

  *Topology and policies are fixed*, and for liveness checks, the path needs to be provided.
]

#centered-slide[
  == Proof? How?
  #pause

  #text(size: 5em)[SMT]
  #v(-4em)

  #pause

  For all edge $A -> B$, generates:

  $
    (and.big "inv(A)"  union "inv"(A -> B) union "inv"(B)) and r' = "Import"(A->B, r) \ -> "inv"(A -> B)[r slash r']
  $ 
]

#slide[
  == Real world deployments

  Hundres of routers, tens of thousands of peering sessions.

  Implemented in C\#, using Zen as SMT library.

  #pause

  11 configuration bugs. Each run takes at most 15 mins.

]

#slide[
  = Conclusion

  #ly is a *modular* way to verify global properties of BGP control plane.

  - Guaranteed correctness for safety and liveness.
  - Constraints are simple to write and understand.
  - Implemented in C\# which can be directly integrated into existing systems.
]

/*
#title-slide[
  == Thank you!

  #v(40pt)

  #image("./look.png", width: 120pt)
]
*/
