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
  footer: [论文分享 - TECC: Towards Efficient QUIC Tunneling via Collaborative Transmission Control],
)

#title-slide[
  = 论文分享 - TECC: Towards Efficient QUIC Tunneling via Collaborative Transmission Control

  #v(1em)

  #text(size: 0.6em)[
    Jiaxing Zhang#super[1,2], Furong Yang#super[1], Ting Liu#super[1,2], Qinghua Wu#super[2,3], Wu Zhao#super[1], Yuanbo Zhang#super[1], Wentao Chen#super[1], Yanmei Liu#super[1], Hongyu Guo#super[1], Yunfei Ma#super[1], Zhenyu Li#super[2,3]

    #super[1] Alibaba Group, #super[2] University of Chinese Academy of Sciences, #super[3] Purple Mountain Laboratories, China
  ]
]

#focus-slide(background: color.lime.darken(50%))[
  == TL;DR
]

#slide[
  == Background

  #v(-1em)

  QUIC-in-QUIC (mostly H3-in-H3) might be desirable:
  - Application Gateway
  - Load balancer
  - VPN / Private Relay

  #only("2")[rfc9297 & rfc9298 "MASQUE"]
  #only("3")[rfc9297 & rfc9298 "MAS#text(weight:"bold")[Q]UE"]
  #only("3-")[: Multiplexed Application Substrate over *QUIC* Encryption]
]

#slide[
  == Background#only("2-")[ a.k.a. The Problem]

  #v(-1em)

  Datagrams travels inside the tunnel in two modes:
  - Each connection = 1 stream
  - Directly sent as unreliable QUIC datagram

  #pause

  Problem:
  - *Retransmission*: can happen at both level, outer retransmission messes with inner congestion ctrl.
  - *Congestion control*: inner and outer congestion ctrl may behave differently.
]

#slide[
  == Retransmission or not?

  #v(-1em)

  #align(center)[
    #image("retransmission.png", width: 80%)
  ]

  #pause

  Datagram mode with retransmission works the best.
]

#slide[
  == Nested Congestion Control

  #v(-1em)

  #align(center)[
    Less congestion #only("1")[$=>$]#only("2")[$arrow.r.double.not$] Faster E2E time#only("1")[?]#only("2")[!]

    #pause
  
    #image("nested-cc-problem.png", width: 60%)
  ]
]

#slide[
  == Nested Congestion Control
  #v(-1em)

  #align(center)[
    #image("nested-cc-diagram.png", height: 80%)
  ]
]

#slide[
  == A Dilemma

  #list-one-by-one[
    No retransmission on tunnel $=>$ Long flow completion time(FCT) on short messages
  ][
    Has retransmission on tunnel $=>$ *Packet drops becomes invisible to E2E server!* Inner congestion control lags behind
  ]
]

#slide[
  == TECC

  - Keep RMDT (Datagram mode with retransmission)
  - Enable collaborative congestion control


  1. Tunnel send *bandwidth* and *queue* information to server
  2. Server updates it pacing (sending rate)

  #pause
  $
  S r(t) = mu dot T r (t) + lambda \
  $

  #pause
  
  *Servers don't use local data to do CC!*
]

#slide[
  == TECC

  #v(-1em)

  - Matching sending rates at server and tunnel egress
  - Penalize large queue usage for fairness

  Ideally: $S r(t) = T r (t) - q(t) slash theta$.

  $theta$ repersents the penality given by queue size.

  #pause

  Also: Expect sudden drop in bandwidth

  #pause

  Finally: Exponentially Weighted Moving Average to dampen the reports
]

#slide[
  == TECC
  #v(-2em)
  #image("alg.png", width: 70%)
]

#slide[
  == Questions Unanswered by the Paper

  #v(-1em)

  1. Parameters $theta, T_s$ depends on *real RTT*, is this approximated in runtime by smoothed detected RTT?
  2. Is using server data to assist in CC able to produce some better result?
  3. A lot of parameters are set based on experimentation. Can it be explained?
]

#slide[
  Anyway...
  #v(-0.8em)
  #pause
  == Evaluation!

  #v(-1em)

  #pause

  - Extra good in mobile network! Performs very well under high (15%) packet loss rate.

  #v(-0.8em)

  #pause

  - #image("fairness.png", width: 78%)
]

#slide[
  == In realworld...
  #image("realworld.png", width: 70%)
]

/*
#title-slide[
  == Thank you!

  #v(40pt)

  #image("./look.png", width: 120pt)
]
*/
