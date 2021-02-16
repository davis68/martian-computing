#   Nock I

![](../img/38-header-neptune-0.png){: width=100%}

##  Learning Objectives

-   Explain how Nock structures map to Hoon.
-   Compile Hoon code to Nock using `!.`.
-   Translate and annotate Nock like assembly language.


##  For Those About to Nock ([We Salute You](https://www.youtube.com/watch?v=qsaTFcXVCNU))

![](../img/38-header-neptune-1.png){: width=100%}

Nock is a [combinator calculus](https://en.wikipedia.org/wiki/Combinatory_logic) (as opposed to a lambda calculus, which is merely an alternative formulation).  All Nock programs are [directed acyclic graphs](https://en.wikipedia.org/wiki/Directed_acyclic_graph), with no cyclical data structures.

In my estimation, Nock should not be considered a programming language so much as a virtual machine standard.

### The Rules

Let's start by examining the eleven basic rules of Nock 4K:

```nock
*[a 0 b]            /[b a]
*[a 1 b]            b
*[a 2 b c]          *[*[a b] *[a c]]
*[a 3 b]            ?*[a b]
*[a 4 b]            +*[a b]
*[a 5 b c]          =[*[a b] *[a c]]

*[a 6 b c d]        *[a *[[c d] 0 *[[2 3] 0 *[a 4 4 b]]]]
*[a 7 b c]          *[*[a b] c]
*[a 8 b c]          *[[*[a b] a] c]
*[a 9 b c]          *[*[a c] 2 [0 1] 0 b]
*[a 10 [b c] d]     #[b *[a c] *[a d]]

*[a 11 [b c] d]     *[[*[a c] *[a d]] 0 3]
*[a 11 b c]         *[a c]
```

These rely on a few definitions given earlier in the [specifications document](https://urbit.org/docs/tutorials/nock/definition/), which we will introduce in our commentary as necessary.

Notice that every Nock formula is a cell.

```nock
*[a 0 b]            /[b a]
```

Rule Zero is an addressing rule.  In other words, it reduces to the noun at address `b` in `a`.  (`/` is the `slot` operator, describing an addressing operation.)

```nock
*[a 1 b]            b
```

Rule One is a constant reduction, returning the bare value `b`.

```nock
*[a 2 b c]          *[*[a b] *[a c]]
```

Rule Two resolves `b` and `c` against the subject, then computes with the result of `b` as the subject of formula `c`.  (`*` is the Nock interpreter with the head of the cell being the subject and the tail of the cell being the formula.)

```nock
*[a 3 b]            ?*[a b]
```

Rule Three is a test on whether `b` is a cell.  (`?` produces `0`/`True` if a cell, `1`/`False` if an atom.)

```nock
*[a 4 b]            +*[a b]
```

Rule Four is an increment operation on `b`.  (`+` increments atom `b`.)

```nock
*[a 5 b c]          =[*[a b] *[a c]]
```

Rule Five is a test for equality of the products of `b` and `c` after computing them against the subject `a`.

```nock
*[a 6 b c d]        *[a *[[c d] 0 *[[2 3] 0 *[a 4 4 b]]]]
```

Rule Six is an `if`/`then`/`else` statement agains the subject.  `if b then c else d`.

```nock
*[a 7 b c]          *[*[a b] c]
```

Rule Seven composes two formulas together.

```nock
*[a 8 b c]          *[[*[a b] a] c]
```

Rule Eight is a stack push or variable declaration, computing `c` against a wrapped subject of `a` and `b`.

```nock
*[a 9 b c]          *[*[a c] 2 [0 1] 0 b]
```

Rule Nine computes `c` against the current subject `a`, then extracts a formula at address `b`.  This is a Hoon-targeted rule, which produces a core and points to an arm.

```nock
*[\a 10 [b c] d]     #[b *[a c] *[a d]]
```

Rule Ten computes `c` and `d`, then replaces `b` in `d` with `c`.

```nock
*[a 11 [b c] d]     *[[*[a c] *[a d]] 0 3]
*[a 11 b c]         *[a c]
```

Rule Eleven takes two forms, one for a cell `[b c]` and another for an atom `b`.  (Note that `d` in the first and `c` in the second play similar roles.)  Rule Eleven provides a hint equal to `c`.  What this means is that the interpreter can use this to compute an expression more efficiently or use the discarded value as a side effect.  (The `~` sig runes are architected around Rule Eleven.)

There's also "fake Nock" Rule Twelve, `.^` dotket, which exposes a namespace into Arvo.

- Reading: [Tlon Corporation, "Nock Definition"](https://urbit.org/docs/tutorials/nock/definition/)
- Reading: [Tlon Corporation, "Nock Explanation"](https://urbit.org/docs/tutorials/nock/explanation/)


##  Calculating Nock

![](../img/38-header-neptune-2.png){: width=100%}

Nock is a standard of behavior, not necessarily an actual machine.  (It _is_ an actual machine, of course, as a fallback, but the point is that any Nock virtual machine should implement the same behavior.)  I like to think of this like solving a matrix.  Formally, given an equation

$$
A \vec{x} = \vec{b}
$$

the solution should be obtained as

$$
A^{-1} A \vec{x} = A^{-1} \vec{b} \rightarrow \vec{x} = A^{-1} \vec{b}
$$

This is correct, but often computationally inefficient to achieve.  Therefore we use this behavior as a standard definition for $\vec{x}$, but may actually obtain $\vec{x}$ using [other more efficient methods](https://boostedml.com/2020/04/solving-full-rank-linear-least-squares-without-matrix-inversion-in-python-and-numpy.html).

Keep that in mind with Nock:  you have to know the specification but you don't have to implement it this way (thus, jet-accelerated Nock).

### By Hand

`!,` zapcom was the undocumented rune which we used to parse Hoon code.  Similarly, there is a a rune [`!=` zaptis](https://urbit.org/docs/reference/hoon-expressions/rune/zap/#zaptis) that produces the Nock formula given a Hoon expression.

```hoon
> !=(+(1))
[4 1 1]
> !=((add 1 1))
[8 [9 36 0 1.023] 9 2 10 [6 [7 [0 3] 1 1] 7 [0 3] 1 1] 0 2]
```

We will use [`.*` dottar](https://urbit.org/docs/reference/hoon-expressions/rune/dot/#dottar) to run Nock.  This rune accepts a subject and a Nock formula.

```hoon
> .*(5 [4 1 1])
2
```

We have a bit of a problem in interpreting these at this point.  For instance, why does an increment operator have two pieces after it, and how does this match Rule Four (`*[a 4 b] → +*[a b]`) anyway?

Every Nock operator has a subject and a formula.  For our purposes, we can think of the subject as the argument.  In this case, `[4 1 1]` is really `[4 [1 1]]` operating on the subject `5`.  But Rule One is a constant reduction, thus returning only `1` (leaving the subject/argument unexamined), which is then operated on by Rule Four to increment.

Thus this way of writing things seems a bit odd, because it hard-codes the constant `sample` into the function rather than dynamically retrieving it from the subject.  Contrast the following and meditate upon them:

```hoon
> .*(5 [4 1 1])
2
> .*(5 [4 1 5])
6
> .*(5 [4 0 1])
6
> .*(5 [4 0 5])
dojo: hoon expression failed
```

Okay, so the way that we are going to read Nock is:

1. Identify the subject and the formula.
2. Figure out the structure of the formula.
3. Nest in recursively until we reach irreducible parts.

(Alternatively, start at the innermost piece and step back out in the same manner.)

Infamously, Nock does not have a native decrement operator, only an increment (Rule Four).  Let us dissect a simple decrement operation in Nock:

```hoon
> !=(|=(a=@ =+(b=0 |-(?:(=(a +(b)) b $(b +(b)))))))
[ 8
  [1 0]
  [1 8 [1 0] 8 [1 6 [5 [0 30] 4 0 6] [0 6] 9 2 10 [6 4 0 6] 0 1] 9 2 0 1]
  0
  1
]
```

which can be restated in one line as

```nock
[8 [[1 0] [1 8 [1 0] 8 [1 6 [5 [0 30] 4 0 6] [0 6] 9 2 10 [6 4 0 6] 0 1] 9 2 0 1] 0 1]]
```

or in many lines as

```nock
[8
  [1 0]
  [1 [8
       [1 0]
       [8
         [1 [6
              [5
                [0 30]
                [4 0 6]
              ]
              [0 6]
              [9
                2
                [10
                  [6 4 0 6]
                  [0 1]
                ]
              ]
            ]
           [9 2 0 1]
         ]
       ]
     ]
  ]
  [0 1]
]
```

(It's advantageous to see both.)

We can pattern-match a bit to figure out what the pieces of the Nock are supposed to be in higher-level Hoon.  From the Hoon, we can expect to see a few kinds of structures:  a trap, a test, a `sample`.  At a glance, we seem to see Rules One, Five, Six, Eight, and Nine being used.  Let's dig in.

(Do you see all those `0 6` pieces?  Rule Zero means to grab a value from an address, and what's at address `6`?  The `sample`, we'll need that frequently.)

The outermost rule is Rule Eight `*[a 8 b c]→*[[*[a b] a] c]` computed against an unknown subject (because this is a gate).  It has two children, the `b` `[0 1]` and the `c` which is much longer.  Rule Eight is a sugar formula which essentially says, run `*[a b]` and then make that the head of a new subject, then compute `c` against that new subject.  `[0 1]` grabs the first argument of the `sample` in the `payload`, which is represented in Hoon by `a=@`.

The main formula is then the body of the gate.  It's another Rule Eight, this time to calculate the `b=0` line of the Hoon.

There's a Rule One, or constant reduction to return the bare value resulting from the formula.

Then one more Rule Eight (the last one!).  This one creates the default subject for the trap `$`; this is implicit in Hoon.

Next, a Rule Six.  This is an `if`/`then`/`else` clause, so we expect a test and two branches.

- The test is calculated with Rule Five, an equality test between the address `30` of the subject and the increment of the `sample`.  In Hoon, `=(a +(b))`.

- The `[0 6]` returns the `sample` address.

- The other branch is a Rule Nine reboot of the subject via Rule Ten.  Note the `[4 0 6]` increment of the `sample`.

Finally, Rule Nine is invoked with `[9 2 0 1]`, which grabs a particular arm of the subject and executes it.

Contrast the built-in `++dec` arm:

```nock
> !=((dec 1))
[8 [9 2.398 0 1.023] 9 2 10 [6 7 [0 3] 1 1] 0 2]
```

for which the Hoon is:

```hoon
++  dec
  |=  a=@
  ?<  =(0 a)
  =+  b=0
  |-  ^-  @
  ?:  =(a +(b))  b
  $(b +(b))
```

Scan for pieces you recognize:  the beginning of a cell is frequently the rule being applied.

In tall form,

```hoon
[8
  [9
    [2.398 [0 1.023]]
  ]
  [9 2
       [10
         [6 7 [0 3] 1 1]
         [0 2]
       ]
  ]
]
```

What's going on with the above `++dec` is that the Arvo-shaped subject is being addressed into at `2.398`, then some internal Rule Nine/Ten/Six/Seven processing happens.

The other major concept you need to wrap your head around to correctly interpret Nock is the distribution rule or “implicit cons”, covered in `~timluc-miptev`'s Part 1 below.  **You should read the following in full.**

- Reading: [`~timluc-miptev`, "Nock for Everyday Coders, Part 1: Basic Functions and Opcodes"](https://blog.timlucmiptev.space/part1.html)
- Reading: [`~timluc-miptev`, "Nock for Everyday Coders, Part 2: The Rest of Nock and Some Real-World Code"](https://blog.timlucmiptev.space/part2.html)
- Reading: [`~timluc-miptev`, "Nock for Everyday Coders, Part 3: Nock Design Patterns"](https://blog.timlucmiptev.space/part3.html)
- Reading: [`~timluc-miptev`, "Nock for Everyday Coders, Interlude FAQ"](https://blog.timlucmiptev.space/faq.html)

### By Machine

Given a Nock formula, how can one acquire a result with Dojo?  `.*` dottar, of course, but also the [`++mock`](https://urbit.org/docs/reference/library/4n/#mock) virtualization arm computes a formula.  `++mock` is Nock in Nock, however, so it is not very fast or efficient.

`++mock` returns a tagged cell, which indicates the kinds of things that can go awry:

- `%0` indicates success
- `%1` indicates a blocked calculation
- `%2` indicates a crash with stack trace

`++mock` is used in Gall and Hoon to virtualize Nock calculations and intercept scrys.  It is also used in Aqua, the testnet infrastructure of virtual ships.

### Vere API

The `u3n` interface implements Nock computation for Vere.

> The nice thing about `++mock` functions is that (by executing within `u3m_soft_run()`, which as you may recall uses a nested road) they provide both exceptions and the namespace operator `.^` dotket in Hoon, which becomes operator `11` in `++mock`.

Thus the binary can handle exceptions and crashes which are formally undefined in Nock but necessary on any real system.

- Reading: [Tlon Corporation, "Vere API Overview by Prefix"](https://urbit.org/docs/tutorials/vere/api/), section `u3n`

### Nock Implementations

It would be a worthwhile endeavor to compose a Nock interpreter in a language of your choice.  (These aren't full Arvo interpreters, of course, since you don't have the Hoon, `%zuse`, and vane subject present.)

- Reading: [Nock Implementations](https://urbit.org/docs/tutorials/nock/implementations/)


##  Archæology

If you are interested in the very early history of Watt (which became Hoon), you can read more on the original specs here:

- Optional Reading: [Curtis Yarvin, "Anatomy of Watt, Part 1:  Molds"](https://github.com/cgyarvin/urbit/blob/master/Spec/watt/1-anatomy.txt)
- Optional Reading: [Curtis Yarvin, "Anatomy of Watt, Part 2:  Genes"](https://github.com/cgyarvin/urbit/blob/master/Spec/watt/2-anatomy.txt)
- Optional Reading: [Bayle Shanks, "Urbit Cheatsheet"](http://www.bayleshanks.com/wiki.pl/notes-computer-programming-hoon-hoonCheatSheet)
- Optional Reading: [Tlon Corporation, "Urbit: a personal cloud computer"](https://archive.is/z0Kwz), Nov. 2014  <!-- XXX important -->
