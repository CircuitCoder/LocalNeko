#import "@preview/polylux:0.4.0": *
#import "../lib/commute/lib.typ": node, arr, commutative-diagram

#set page(paper: "presentation-16-9")

#set text(
  font: ("Noto Serif", "Source Han Serif SC"),
  size: 24pt,
)

#slide[
  #set align(horizon + center)
  = 数字文本渲染 101

  #v(20pt)

  喵喵

  #v(20pt)

  #image("./float.png", width: 120pt)
]

#slide[
  #set align(horizon)
  #only("1")[
    #commutative-diagram(
      node((0, 0), "DNA", "1"),
      node((0, 2), "RNA", "2"),
      node((0, 4), "Protein", "3"),
      arr("1", "2", text(size: 0.6em)[转录]),
      arr("2", "3", text(size: 0.6em)[翻译]),
    )
  ]
  #only("2-")[
    #commutative-diagram(
      node((0, 0), "Codepoint", "1"),
      node((0, 2), "Glyph", "2"),
      node((0, 4), "Pixels", "3"),
      arr("1", "2", text(size: 0.6em)[Shaping]),
      arr("2", "3", text(size: 0.6em)[Rasterization]),
    )
  ]

  #show: later
  #show: later
  #set align(left)
  #item-by-item(start: 3)[
  - 怎么生成一个字体子集
  - “为什么浏览器这么慢！”
  - #image("./FOX.png", width: 200pt)
  ]
]

#let title-slide(input, content) = slide[
  #set page(fill: color.lighten(blue, 70%))
  #set align(center + horizon)

  #text(size: 54pt, weight: 900)[#input]

  #content
]

#title-slide("文字存储/编码")[]

#slide[
  #set align(horizon + center)
  当然是存储在硬盘/内存/NFS mount/云/纸上....
  #show: later
  #image("./UTF.png", height: 1fr)
]

#slide[
  // https://emojipedia.org/family-woman-light-skin-tone-woman-light-skin-tone-girl-light-skin-tone-boy-light-skin-tone
  
  == Unicode gives us 👩🏻‍👩🏻‍👧🏻‍👦🏻

  #v(1em)

  whatwg: now the mandatory encoding for all things

  #show: later

  "字符" $->$ 码位 (Codepoint)

  #show: later

  *注意*: 字符集（码位分配）和编码有区别！

  - #only("3")[UTF-8] #only("4-")[*UTF-8 (> 99%)*]
  - UTF-16LE/BE & UCS-2
  - UTF-32
  - _Other_ rounding errors (GB.\*, BIG5, etc.)
]

#slide[
  == UTF-8

  #v(0.5em)

  #show: later
  
  Consider UTF-16/UCS-2:
  #text(size: 0.8em)[
  - ASCII-incompatible!
  - 需要区别 LE & BE
  - 支持的 Plane 比较少（可用比特比较少）
  - 导致 `0xD800` - `0xDFFF` 无法使用
  ]

  #show: later

  #image("./UTF-8.png", height: 1fr)
]

#slide[
  == ZWJ sequences

  #set align(top)

  #columns(2, gutter: -4em)[
    Array.from(#box[#image("./family.png")]) = 

    ```
    [
      '👩', '🏻', '‍',
      '👩', '🏻', '‍',
      '👧', '🏻', '‍',
      '👦', '🏻'
    ]
    ```

    // 🏿
    // 👩🏻‍👩🏻‍👧🏻‍👦🏻: d & w

    #show: later

    #box(height: 80%)[
      #align(horizon)[
        - UTF-8 $=>$ Codepoints
        - Codepoints 可能每个对应多个字符，不到一个字符，或者其他情况。
      ]
    ]
  ]
]

#title-slide("Shaping")[]

#slide[
  == Shaping
  #v(0.5em)
  将文字 + 字体转换为排版与字形的过程
]

#slide[
  #set page(fill: color.lighten(blue, 70%))
  #set align(center + horizon)

  #text(size: 54pt, weight: 900)[Wait a minute...]

  #show: later

  为什么已经开始讲字体和字形了？
]

#slide[
  == It turns out...

  #v(1em)

  字体需要考虑字符集！

  #show: later

  #image("./opentype-encoding.png", height: 1fr);
]

#slide[
  == The CMAP table
  #v(0.5em)
  Codepoint $->$ Glyph ID (16-bit)

  #show: later

  Segmented coverage (format 12): 
  ```Rust
  struct Group {
    start: u32,
    end: u32,
    glyphStart: u32,
  }
  type Subtable13 = Vec<Group>;
  ```
]

#slide[
  == The GLYF table
  #commutative-diagram(
    node((0, 0), "Glyph ID", "1"),
    node((0, 2), "Glyph Definition", "2"),
    arr("1", "2", text(size: 0.6em)[LOCA])
  )

  得到：一系列 Bezier curve 控制点

  #show: later

  #align(center)[
    #image("./ok.jpg", height: 1fr)
  ]
]

#slide[
  #place(center + horizon)[
    #image("./ttf-instr.png", height: 350pt)
  ]
  #show: later
  #place(
    center + horizon,
    image("./sweat.jpg", height: 250pt)
  )

  #footnote(
    text(size: 0.5em)[
    https://learn.microsoft.com/en-us/typography/opentype/spec/tt_instructions])
]

#slide[
  == What about...
  #show: later
  #item-by-item(start: 2)[
  - Ligatures
  - Kerning
  - Layout
  - Variable font
  ]
]

#slide[
  #figure(caption: [Wrong #strike[warp] wrap])[
    #image("./wrongwrap.jpg")
  ]
]

#slide[
  == Layout

  #v(1em)

  每个字符有一个 Horizontal Advance 表示下一个字符应该在横向前进多少。

  e.g. 对于空格，有 Horizontal advacement，但是 Glyph Data 里面没有任何点。

  #show: later

  - hmtx
  - phantom points
]

#slide[
  == What about line-breaks

  UAX#footnote[Unicode® Standard Annex] #14: Unicode Line Breaking Algorithm

  #show: later

  - Mandatory line breaks
  - Available line breaks
]

#slide[
  #set align(horizon + center)
  - UAX #29: Unicode Text Segmentation
  - UAX #15: Unicode Normalization Forms
]

#slide[
  == Kerning & Ligatures

  #v(1em)

  最开始：KERN table

  #show: later

  Post-CFF2:
  #item-by-item(start: 2)[
    - GPOS
    - GSUB
  ]

  #only("4-")[
    #image("./ligatures.png", height: 1fr)
  ]
]

#slide[
  == Variations...

  #v(1em)

  There is a GVAR table...

  #show: later

  #uncover("3-")[
    #image("./cmp-header.png", width: 100%)
  ]
  #v(-1em)
  #image("./cmp.png", width: 100%)
]

#title-slide("Rendering")[]

#slide[
  == Vector rendering 101

  #v(0.5em)

  #align(center + horizon)[
    ```Rust
    for pixel in screen {
      pixel.color = if path.contains(pixel) {
        black
      } else {
        white
      };
    }
    ```
  ]

  #only(2)[
    #place(
      center + horizon,
      image("./sleep.png", height: 250pt)
    )
  ]

  #only(3)[
    #place(
      center + horizon,
      image("./wake.png", height: 250pt)
    )
  ]

  #only(4)[
    #place(
      center + horizon,
      image("./aliasing.png", height: 100pt)
    )
  ]

  #only(5)[
    #place(
      center + horizon,
      image("./aliasing.png", height: 500pt)
    )
  ]
]

#slide[
  == Vector rendering 102

  #v(0.5em)
  Path-winding number

  #show: later

  #align(center)[
    #image("./winding-num.png", height: 1fr)
  ]

  #show: later

  Flatten to segments
]

#slide[
  == Scale animation

  #v(1em)

  缩放 SVG 非常慢，为何浏览器 `transition: transform` 在文字上这么快？

  #only(1)[
    群友: `Bitmap interpolation`
  ]
  #only("2-")[
    群友: `Blur(Bitmap interpolation)`
  ]

  #show: later
]

#slide[
  == Anti-aliasing

  #v(1em)

  #only("1")[
    ```Rust
    for pixel in screen {
      pixel.color = if path.contains(pixel) {
        black
      } else {
        white
      };
    }
    ```
  ]

  #only("2")[
    ```Rust
    for pixel in screen {
      pixel.color
        = black * path.intersection_ratio(pixel);
    }
    ```
  ]

  #only("3")[
    ```Rust
    for pixel in screen {
      let mut total: f64 = 0;
      for subpixels in pixel.subpixels() {
        subpixels.on = path.contains(subpixels);
      }
    }
    ```
  ]


  #only("4-")[
    ```Rust
    for diode in screen {
      diodes.on = path.contains(diodes);
    }
    ```
  ]

  #only("5")[
    #image("./FOX.png")
  ]
]

#slide[
  #set align(horizon + center)
  == Question time!
  #v(20pt)

  #image("./look.png", width: 120pt)

  https://layered.meow.plus
]
