#import "@preview/polylux:0.4.0": *
#import "@preview/shadowed:0.2.0": shadowed

#set page(paper: "presentation-16-9")

#set text(
  font: ("Source Serif Pro"),
  size: 24pt,
)

#let meow-slide(body) = slide[
  #place(bottom+right, dx: 40pt, dy: 40pt)[
    #toolbox.progress-ratio(ratio => {
      stack(
        dir: ltr,
        rect(stroke: gray, fill: gray, width: ratio       * 200pt, height: 5pt),
        rect(stroke: gray, fill: none, width: (1 - ratio) * 200pt, height: 5pt),
        rect(width: 20pt, stroke: none),
        [#toolbox.slide-number / #toolbox.last-slide-number],
      )
    })
  ]
  #body
]


#slide[
  #set align(horizon + center)
  = Amortized Complexity of Information-Theoretically Secure MPC Revisited#footnote[eprint 2018/429]

  Ignacio Cascudo, Ronald Cramer, Chaoping Xing, and Chen Yuan

  #v(10pt)

  Presenter: Liu Xiaoyi
]

#meow-slide[
  In the BGW-model...
  #v(-20pt)
  #text(size: 1.5em)[How to use SIMD to squeeze more "computation" into a single computation pass?]
  #v(-20pt)

  #show: later

  #line(length: 100%)
  
  With packed Shamir secret sharing.

  $Omega(n)$ parallel instances: $O(n) -> O(1)$ communication per multiplication gate.
  #show: later

  SSS requires a "large enough" field. Can we encode multiple elements in the base field together? e.g. when the base field is small ($FF_2$)
]

#meow-slide[
  #text(gray)[#smallcaps[Introduction]]
  #v(-20pt)
  == Squeezing elements together
  Namely, can we have a map: $phi.alt: FF_q^k -> FF_(q^m)$, and some protocol to evaluate arithmetic circuits "through" $phi.alt$:

  - Input: All parties receives $k$ inputs $bold(x) = (x_1, ..., x_k) in FF_k$.
  - Encode: compute $phi.alt(bold(x)) in FF_(q^m)$
  - Compute: All parties evaluate arithmetic circuit with $phi.alt(bold(x))$ as input, reconstruct output $phi.alt(bold(o)) in FF_(q^m)$
  - Decode: computing $bold(o) = phi.alt^(-1)(phi.alt(bold(o)))$
]

#meow-slide[
  #text(gray)[#smallcaps[Introduction]]
  #v(-20pt)
  == Main result fo the paper
  Yes, we can! And pretty efficiently: $forall q forall k exists m exists phi.alt: FF_q^k -> FF_(q^m)$, \ where $m = O(k)$

  #show: later

  In malicious settings,

  - Modified DN protocol with small fields: Do $Omega(log n)$ parallel computation, $O(n log n) -> O(n)$ bit per gate.
  - Modified DN protocol with small fields and suboptimal threshold: Combine with Packed SSS, $O(log n) -> O(1)$ bit per gate.
]

#meow-slide[
  #text(gray)[#smallcaps[Introduction]]
  #v(-20pt)
  == What is omitted in this presentation

  - The concrete construction of such $phi.alt$, and proof of why can $m = O(k)$. Instead, several praticle parameter choices are given.
  - The detailed handling of player elimination.
]

/*
#slide[
  == Main result fo the paper

  Yes, we can!
  #show: later
  In the BGW model with $n$ parties
  
  - With $t <= (n-1) slash 3$, there is a scheme to compute $Omega(log n)$ evaluations of a same circuit in parallel with an amortized communication cost of $O(n)$ *bits* per gate.
  #show: later
  - For every $epsilon > 0$, with $t < (1-epsilon) n slash 3$, there is a scheme to compute $Omega(log n)$ evaluations of a same circuit in parallel with an amortized communication cost of $O(1)$ bits per gate.
]
*/

#meow-slide[
  == The procedure
  $
  phi.alt: FF_q^k -> FF_(q^m)
  $

  - Input: All parties receives $k$ inputs $bold(x) = (x_1, ..., x_k) in FF_k$.
  - Encode: compute $phi.alt(bold(x)) in FF_(q^m)$
  - Compute: All parties evaluate arithmetic circuit with $phi.alt(bold(x))$ as input, reconstruct output $phi.alt(bold(o)) in FF_(q^m)$
  - Decode: computing $bold(o) = phi.alt^(-1)(phi.alt(bold(o)))$
]

#meow-slide[
  #text(gray)[#smallcaps[Construting the encoding map $phi.alt$]]
  #v(-20pt)
  == "Just use the bits"

  #align(horizon)[
    $
    phi.alt: FF_q^k <-> FF_(q^k)
    $
    #v(30pt)
    #show: later
    ... but multiplication does not work. \ Notably, $FF_q^k$ contains zero divisors for $k >= 2$.
  ]
]

#meow-slide[
  #text(gray)[#smallcaps[Construting the encoding map $phi.alt$]]
  #v(-20pt)
  == #only("-2")[Giving up strict inverse for multiplication]#only("3")[$(k, m)_q-$RMFE #text(size: 0.7em)[(Reverse multiplication friendly embedding)]]

  #v(20pt)

  Define a pair of $FF_q$-linear maps:
  $
  phi.alt: FF_q^k arrows.lr FF_(q^m): psi
  $
  where $psi$ is the *"decode multiplication"* map:
  $
  bold(x) * bold(y) = psi(phi.alt(bold(x)) dot phi.alt(bold(y)))
  $
  #only("2")[
    #place(
      center + top,
      shadowed(inset: 20pt, radius: 10pt)[
        #align(left)[
          All of the following do not necessarily hold:
          - $phi.alt(bold(x) * bold(y)) = phi.alt(bold(x)) dot phi.alt(bold(y))$
          - $bold(x) = psi(phi.alt(bold(x)))$
          - $bold(x) * bold(y) * bold(z) = psi(phi.alt(bold(x)) dot phi.alt(bold(y)) dot phi.alt(bold(z)))$
        ]
      ]
    )
  ]

  #show: later
  #show: later
  *Thm.* Exists $(k,m)_q$-RMFE for all $k, q$ with $m = O(k)$
]

#meow-slide[
  #text(gray)[#smallcaps[Random values from hyper-invertible matrices]]
  #v(-20pt)
  == Random gates

  #one-by-one[
    - ($k$) uniformly random $FF_q$ elements
  ][
    - $phi.alt(r_1, ..., r_k)$ with uniformly random $r_1, ..., r_k in FF_q$
  ][
    - Uniformly random $r' in "Im" phi.alt$ #only("4-")[#h(40pt)$<--$ This is a $FF_q$-linear subspace]
  ]
]

#meow-slide[
  #text(gray)[#smallcaps[Random values from hyper-invertible matrices]]
  #v(-20pt)
  == The hyper-invertible matrices

  #only("1")[$A in FF^(m times n)$ $(n < m)$ is _super-invertible_ if the matrices formed by selecting any $n$ rows of $A$ is invertible.]

  #only("2")[$A in FF^(m times n)$ is _hyper-invertible_ if for all $k <= min(m, n)$, the matrices formed by selecting any $k$ rows and $k$ columns of $A$ is invertible.]

  #only("3-")[$A in FF^(n times n)$ is _hyper-invertible_ if for all $k <= n$, the matrices formed by selecting any $k$ rows and $k$ columns of $A$ is invertible.]

  #show: later
  #show: later
  #show: later

  *Construction*: Select $2n$ evaluation points $alpha_1, ..., alpha_n, beta_1, ..., beta_n$. Consider the $FF$-*linear* map of reconstructing a degree-$(n-1)$ polynomial from $n$ values as evaluations at $alpha_1, ..., alpha_n$, and evaluate the polynomial at $beta_1, ..., beta_n$.

  $
    lambda_(i, j) = product_(k in {1,.., n} without j) (beta_i - alpha_k) / (alpha_j - alpha_k)
  $
]

#meow-slide[
  #text(gray)[#smallcaps[Random values from hyper-invertible matrices]]
  #v(-20pt)
  == $Pi_("RandElIm"phi.alt)$: Generate random elements in $"Im" phi.alt$
  - Fixed public $n times n$ hyper-invertible matrix $M$. $1 <= T <= n - 2t$
  - Outputs: $T$ correct secret sharings of uniformly random $"Im" phi.alt$ elements
  #shadowed(inset: 20pt)[
    #box(width: 100%)[
      - Each party $P_i$ uniformly samples a $s^i in "Im" phi.alt$, shares it.
      - Parties locally computes $([r^1], ..., [r^n])^T = M dot ([s^1], ..., [s^n])^T$
      - For each $T + 1 <= i <= n$, $P_i$ opens $r^i$, and check if it's in $"Im" phi.alt$. If not, complains.
      - Output unopened $[r^1], ..., [r^T]$
    ]
  ]

  #only("2")[
    #place(
      center + top,
      shadowed(inset: 20pt, radius: 10pt)[
        #align(left)[
          Fact: If all honest parties are happy, then $[r^1], ..., [r^T]$ are correct, and adversary has no information of them besides $r^1,... , r^T in "Im" phi.alt$
        ]
      ]
    )
  ]

  #only("3")[
    #place(
      center + bottom,
      shadowed(inset: 20pt, radius: 10pt)[
        #align(left)[
          Where is $M$ and $"Im" phi.alt$ defined upon?
        ]
      ]
    )
  ]
]

#meow-slide[
  #text(gray)[#smallcaps[Tensoring up!]]
  #v(-20pt)
  == Bundling secret sharings together

  Fundmentally, the problem is that the secret space is too small, so the sharing scheme *may not be linear* over the extension field.

  $
    FF_q "vs." FF_(q^m)
  $

  #show: later

  But if we gather $m$ $FF_q$-linear secret sharing together, they can natually form a $FF_(q^m)$-linear secret sharing, while being individually easily accessible.
]

#meow-slide[
  #text(gray)[#smallcaps[Tensoring up!]]
  #v(-20pt)
  == Bundling secret sharings together

  Assume we want to force the secrets to lie in $FF_q$-linear subspace $V subset.eq FF_(q^m)^v$

  If we have $m$ of them, we can form a $m times n$ $FF_q^m$ matrix with everyones' shares.

  $
    vec([x_1], ..., [x_m])
  $
]

#meow-slide[
  #text(gray)[#smallcaps[Tensoring up!]]
  #v(-20pt)
  == $FF_(q^m)$ elements as $FF_q^(m times m)$ matrices

  Fix a basis of $FF_(q^m)$ as a $FF_q$-vector space. Then $forall lambda in FF_(q^m)$:
  $
    lambda dot (-): FF_(q^m) -> FF_(q^m)
  $
  is a linear map. Thus each $lambda$ can be identified with a $FF_q^(m times m)$.

  #show: later

  This induces a (injective) $FF_q$-algebra morphism $Phi: FF_(q^m) -> FF_q^(m times m)$ that fixes $FF_q$:
  $
    forall lambda in FF_q subset.eq FF_(q^m), Phi(lambda) = lambda dot I_(m times m)
  $
]

#meow-slide[
  #text(gray)[#smallcaps[Tensoring up!]]
  #v(-20pt)
  == $FF_(q^m)$ elements as $FF_q^(m times m)$ matrices

  #v(30pt)

  $
    vec([y_1], ..., [y_m]) = lambda dot vec([x_1], ..., [x_m]) eq.def Phi(lambda) dot vec([x_1], ..., [x_m])
  $

  - $x_1, ..., x_m in V => y_1, ..., y_m in V$
  - Compatible with $FF_q$-linear.
]

#meow-slide[
  #text(gray)[#smallcaps[Tensoring up!]]
  #v(-20pt)
  == $Pi_"RandElSub"(V)$: Generate random elements in $V$

  - Fixed $FF_q$-vector subspace $V subset.eq FF_(q^m)^v$.
  - Fixed basis for $FF_(q^m)$ as a $FF_q$-vector space.
  - Fixed public $n times n$ hyper-invertible matrix $M$.
  - $1 <= T <= n - 2t$.
  - Outputs: $T times m$ correct secret sharings of uniformly random $V$ elements

  #shadowed(inset: 20pt)[
    #box(width: 100%)[
      #align(center)[
        Exactly the same as $Pi_("RandElIm"phi.alt)$
      ]
    ]
  ]
]

#meow-slide[
  #text(gray)[#smallcaps[Putting everything together]]
  #v(-20pt)
  == What's missing

  - Multiplication

    $
      (phi.alt circle.tiny psi)(phi.alt(bold(x)) dot phi.alt(bold(y))) = phi.alt(bold(x) * bold(y))
    $

  #show: later
  - Verify input shares
]

#meow-slide[
  #text(gray)[#smallcaps[Putting everything together]]
  #v(-20pt)
  == $Pi_"CorrInput"$: Checking the consistency of sharings

  - Input: A secret sharing $[x]$
  - Output: Accepts if $x in "Im" phi.alt$, rejects otherwise.

  #shadowed(inset: 20pt)[
    #box(width: 100%)[
      - Take an unused $[r]$ from $"RandElSub"("Im" phi.alt)$
      - Computes [x + r], publicly opens it, checks if $x + r in "Im" phi.alt$
    ]
  ]
]

#meow-slide[
  #text(gray)[#smallcaps[Putting everything together]]
  #v(-20pt)
  == $Pi_"ReEncode"$: Computes $phi.alt circle.tiny psi$

  - Input: A secret sharings $[x]$
  - Output: $[phi.alt(psi (x))]$

  #show: later

  #only("2")[
    Notice that $phi.alt circle.tiny psi$ is $FF_q$-linear, but not $FF_(q^m)$-linear, i.e. there may not exists a $lambda in FF_(q^m)$ s.t. $phi.alt circle.tiny psi = lambda dot (-)$

    But: $W = {(x, phi.alt(psi(x))) : x in FF_(q^m)} subset.eq (FF_(q^m))^2$ is a $FF_q$-linear subspace.
  ]

  #show: later

  #only("3")[
    #shadowed(inset: 20pt)[
      #box(width: 100%)[
        - Take an unused $([r], [phi.alt(psi(r))])$ from $"RandElSub"(W)$
        - Computes [x + r], publicly opens it
        - Locally compute $phi.alt(psi(x + r)) - [phi.alt(psi(r))] = [phi.alt(psi(x))]$
      ]
    ]
  ]
]

#meow-slide[
  #text(gray)[#smallcaps[Putting everything together]]
  #v(-20pt)
  == Conclusion

  #set text(size: 0.95em)
  In the BGW-model, there is an efficient MPC protocol for $n$ parties...

  - ...secure against the maximal number of active corruptions $floor.l (n − 1)/3 floor.r$ that computes $Omega(log n)$ evaluations of a single binary circuit in parallel with an amortized communication complexity (per instance) of $O(n)$ bits per gate.

  - For every $epsilon$ > 0, ...secure against a submaximal number of active corruptions $t < (1 − epsilon)n/3$ that computes $Omega(n log n)$ evaluations of a single binary circuit in parallel with an amortized communication complexity (per instance) of $O(1)$ bits per gate.
]

#meow-slide[
  #text(gray)[#smallcaps[RMFE and boolean circuits]]
  #v(-20pt)
  == Concatenation of RMFEs

  If $(phi.alt_1, psi_1)$ is an $(k_1, m_1)_(q^(m_2))$-RMFE, $(phi.alt_2, psi_2)$ is an $(k_2, m_2)_q$-RMFE, then the following pair of map gives a $(k_1 k_2, m_1 m_2)_q$-RMFE:

  $
    (x_1, ..., x_k_1) |-> (phi.alt_2(x_1), ..., phi.alt_2(x_k_1)) |-> phi.alt_1(phi.alt_2(x_1), ..., phi.alt_2(x_k_1)) \
    a |-> psi_1(a) = (u_1, ..., u_k_1) |-> (psi_2(u_1), ..., psi_2(u_k_1))
  $
]

#meow-slide[
  #text(gray)[#smallcaps[RMFE and boolean circuits]]
  #v(-20pt)
  == For boolean circuits

  With $q = 2$, there exists $(3, 5)_2$\-RMFE and a family of $(k, m)_32$-RMFE where $m / k -> 62/21$.

  Thus, there exists a family of $(k, m)_2$-RMFE with $m / k -> 4.92...$
]

#meow-slide[
  #text(gray)[#smallcaps[RMFE and boolean circuits]]
  #v(-20pt)
  == Construction for relatively small $k$

  If $1 <= k <= q + 1$, there exists a $(k, 2k - 1)_q$-RMFE

  Choose any primitive element $a$ of $FF_(q^(2k-1)) slash FF_q$, choose $k$ evaluation points $alpha_1, ..., alpha_k in FF_q union { infinity }$

  $phi.alt$ is defined as (evaluate at $a circle.tiny$ Langrange interpolation)
]

#meow-slide[
  #set align(horizon + center)
  = Thank you!
  == Q&A
]
