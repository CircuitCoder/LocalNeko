#import "@preview/polylux:0.4.0": *
#import "@preview/shadowed:0.2.0": shadowed

#set page(paper: "presentation-16-9")

#set text(
  font: ("Noto Serif", "Source Han Serif SC"),
  size: 24pt,
)

#slide[
  #align(center + horizon)[
    #set text(size: 3em, weight: "bold")
    Rust China Tour

    #v(-1em)
    $times$
    #v(-1em)
    TUNA
  ]
]

#slide[
  #set align(horizon + center)
  = New Stuffs in Trait

  #v(20pt)

  喵喵

  #v(20pt)

  #image("./float.png", width: 120pt)
]

#let title-slide(input, content) = slide[
  #set page(fill: color.lighten(blue, 70%))
  #set align(center + horizon)

  #text(size: 54pt, weight: 900)[#input]

  #content
]

#slide[
  == Motivation for this talk...

  #align(center + horizon)[
    #image("rtn.png", height: 100fr)
  ]

  #show: later

  #place(center + horizon)[
    #shadowed(color: black, dx: 0pt, dy: 4pt, shadow: 6pt)[
      #image("rtn-large.png", height: 50%)
    ]
  ]
]

#title-slide("???")[
  #image("thinking.png", height: 10em)
]

#slide[
  == Trait

  - Typeclasses (for static dispatch and ML folks)
  - Interfaces (for dynamic dispatch and Java folks)

  #show: later

  #set text(size: 0.8em);
  ```rust
    trait Animal {
      fn eat(&mut self);
    }
    trait Cat : Animal {
      fn meow(&self) -> String;
    }
    struct Ouroboros;
    impl Animal for Ouroboros {
      fn eat(&mut self) { self.eat(); }
    }
  ```
]

#slide[
  == Trait

  ```rust
  fn pat<M: Cat>(meow: &mut M) { meow.meow(); }
  ```
  #show: later
  ```rust
  fn pat<M>(meow: &mut M) where M: Cat { meow.meow(); }
  ```
  #show: later
  ```rust
  fn pat(meow: &mut dyn Cat) { meow.meow(); }
  ```
]

#slide[
  == Trait
  ```rust
  fn pat<M: Cat>(meow: &mut M) { feed(meow); }
  ```
  ```rust
  fn pat<M>(meow: &mut M) where M: Cat { feed(meow); }
  ```
  ```rust
  fn pat(meow: &mut dyn M) { feed(meow); }
  ```

  #v(2em)

  #only("1")[
    ```rust
    fn feed_bound<A: Animal>(meow: &mut dyn A) { /* ... */ }
    fn feed_dyn(meow: &mut dyn Animal) { /* ... */ }
    ```
  ]
  #only("2-")[
    ```rust
    fn feed_bound<A: Animal + ?Sized>(meow: &mut dyn A) { /* */ }
    fn feed_dyn(meow: &mut dyn Animal) { /* ... */ }
    ```
  ]

  #show: later
  #show: later

  #v(1em)

  #text(red)[
    ```
    error[E0658]: cannot cast `dyn Cat` to `dyn Animal`, trait upcasting coercion is experimental
    ```
  ]
]

#slide[
  == Upcast

  #show: later
  ```
  dyn Derived -> dyn Base
  ```

  #show: later

  #set text(size: 0.8em)
  ```cpp
#include <cstdint>
#include <iostream>

struct Base {
  uint64_t var;
};
struct Left : Base {
  uint64_t get() { return var; }
};
struct Right : Base {
  void set(uint64_t i) { var = i; }
};
struct Center : public Left, public Right {};
  ```
]

#slide[
  == Upcast

  #v(1em)

  There is data stored in...

  #show: later

  #align(center)[
    #box[#image("./fat.png", width: 5em)]-pointers
  ]

  ... namely the vtable
]

#slide[
  == Trait object upcasting support

  #v(1em)

  - New vtable format s.t. subtraits can navigate to vtable of supertraits from their own vtable
  - New unsized coercion rules: `dyn T -> dyn U` where `T: U`
    - Allows `&dyn T -> &dyn U`, `Box<dyn T> -> Box<dyn U>`, so on.
  
  #show: later

  #v(2em)

  *Stablized on Feb 8*, next stable
]

#title-slide("The coloring problem")[
  #image("coloring.png", height: 10em)
]

#slide[
  #align(center+horizon)[
    #only(1)[
      ```rust
      fn opt<T>(pred: bool, v: T) -> Option<T> {
          if pred { Some(v) } else { None }
      }
      ```
    ]
    #only("2-")[
      ```rust
      const fn opt<T>(pred: bool, v: T) -> Option<T> {
          if pred { Some(v) } else { None }
      }
      ```
    ]

    #show: later
    #show: later

    #v(2em)

    #text(red)[
      ```
      error[E0493]: destructor of `T` cannot be evaluated at compile-time
      ```
    ]
  ]
]

#slide[
  #align(center+horizon)[
    ```rust
    #![feature(const_destruct)]
    #![feature(const_trait_impl)]

    fn opt<T>(pred: bool, v: T) -> Option<T>
      where T: ~const std::marker::Destruct
    {
        if pred { Some(v) } else { None }
    }
    ```
  ]
]

#title-slide(`~const Trait`)[
  #image("thinking.png", height: 10em)
]

#slide[
  == Const implementable traits

  ```rust
#[const_trait]
trait Tr {
    fn meow(self);
}
struct M;
impl const Tr for M {
    fn meow(self) {}
} 

const fn test<T: ~const Tr>(v: T) {
    v.meow()
}
  ```
]

#slide[
  == "Part of the trait is const"

  #v(1em)

  #show: later

  #item-by-item(start: 2)[
    - #strike[Too bad, try zig]
    - Recall that `const` means "*CAN* be evaluated at compile time"
    - Wait for keyword generics (`#![feature(effects)]`), maybe stablized in Rust 2099.
  ]

  #show: later
  #show: later
  #show: later

  Compiler dev guide#footnote[https://rustc-dev-guide.rust-lang.org/effects.html] & "Extending Rust's Effect System" by Yoshua Wuyts#footnote[https://blog.yoshuawuyts.com/extending-rusts-effect-system/]

  #show: later

  #place(center + horizon)[
    #shadowed(color: black, dx: 0pt, dy: 4pt, shadow: 6pt)[
      #image("./haskell.png", width: 30em)
    ]

    #show: later
    #shadowed(color: black, dx: 0pt, dy: 4pt, shadow: 6pt, inset: 15pt)[
      New keyword -> New sort -> Polymorphism!
    ]
  ]
]

#slide[
  == What about async
  Traditionally...
  ```rust
  trait Bad {
    async fn bad(&self) -> i32;
  }

  trait Good {
    fn bad(&self) -> Box<dyn Future<Output = i32>>;
  }
  ```
]

#slide[
  == What about async

  #show: later

  #image("AFIT-announcement.png")

  #show: later

  #place(center + horizon)[
    #shadowed(color: black, dx: 0pt, dy: 4pt, shadow: 6pt)[
      #image("./AFIT-syntax.png", width: 20em)
    ]
  ]
]

#slide[
  == What about async
  #image("AFIT-announcement.png")
]

#title-slide("Those (types) who cannot be named")[
  #image("monster.png", height: 7em)
]

#slide[
  == Desugaring AFIT
  #v(2em)

  #align(center)[
    AFIT #only("2-")[$->$ RPITIT]#only("3-")[$->$ Anonymous [G]AT]
  ]
  #v(2em)
  #only("1")[
  ```rust
  trait Meow {
    type Item: Copy;
    async fn meow(&self) -> Self::Item;
  }
  ```
  ]

  #only("2")[
  ```rust
  trait Meow {
    type Item: Copy;
    fn meow(&self) -> impl Future<Output = Self::Item>;
  }
  ```
  ]

  #only("3")[
  ```rust
  trait Meow {
    type Item: Copy;
    type __fut__: Future<Output = Self::Item>;
    fn meow(&self) -> Self::__fut__;
  }
  ```
  ]
]

#slide[
  == Desugared impl

  #v(2em)

  ```rust
  impl Meow for T {
    type Item = i32;
    type __fut__ = impl Future<Output = Self::Item>;
    fn meow(&self) -> Self::__fut__ {
      async move { 42 }
    }
  }
  ```

  #show: later

  Wait for *`impl Trait` in associated type*.
]

#slide[
  #set align(horizon + center)
  == Question time!
  #v(20pt)

  #image("./look.png", width: 120pt)

  https://layered.meow.plus
]
