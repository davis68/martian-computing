#   Nock II

![](../img/39-header-pluto-0.png){: width=100%}

##  Learning Objectives

-   Explain the role of jets and how jets are matched (in `u3j`).
-   Examine how jets underlie key Nock code.
-   Outline the past and future history of Nock.


##  Jetting

Nock in a sense represents a standard rather than an actual execution engine.  The execution engine is always there as a fallback, but you can match out code equivalents to jets, which are optimized registered subroutines on the hosting machine.  (Jets are named such from "jet-accelerated Nock".)

Jets are commonly written in C (although I believe this is not required:  C++ is also an option).  Jet composition assumes a fair bit of familiarity with Vere internals.  We should consider the following from the API:

### Noun Management with `u3a`, `u3i`, `u3r`

| Prefix | Purpose |
| ------ | ------- |
| `u3a`  | allocation |
| `u3i`  | noun construction |
| `u3j`  | jet control |
| `u3r`  | noun access (error returns) |

A noun is an unsigned integer (`u3a_atom`) or a cell (`u3a_cell`).

```c
typedef struct {
  c3_w mug_w;
  c3_w len_w;
  c3_w buf_w[0];    //  actually [len_w]
} u3a_atom;

typedef struct {
  c3_w    mug_w;
  u3_noun hed;
  u3_noun tel;
} u3a_cell;
```

`mug_w` is a hash; `len_w` is the length of the atom in bytes; `buf_w` is the buffer containing the data; `hed` and `tel` are the head and tail nouns of the cell.

An integer that fits in 31 bits is a direct atom and may be treated normally.  Larger atoms are indicated by the 32nd bit (bit `31`) being set to `1`.  This necessitates creating values in C via the `u3i` constructors like `u3i_string` and grabbing values in C via the `u3r` methods like `u3r_words`.

Nouns are reference-counted, which means keeping track within functions.  Functions may have _transfer_ semantics (meaning the reference count responsibility is passed to the new function) or _retain_ semantics (meaning the reference count responsibility does not transfer).  This is a bit of a pain in practice but not terrible, certainly no worse than `new`/`delete`, `malloc`/`free`, and the like.

The allocation routines are implemented to preserve road integrity:

> You can't call `malloc` (or C++ `new`) in your C code, because you don't have the right to modify data structures at the global level, and will leave them in an inconsistent state if your inner road gets terminated.  (Instead, use our drop-in replacements, `u3a_malloc()`, `u3a_free()`, `u3a_realloc()`.)

- Reading: [Tlon Corporation, "Land of Nouns"](https://urbit.org/docs/tutorials/vere/nouns/)


### Making a Jet

| Prefix | Purpose |
| ------ | ------- |
| `u3k[a-g]` | jets (transfer, C args) |
| `u3q[a-g]` | jets (retain, C args) |
| `u3w[a-g]` | jets (retain, nock core) |

Jets are registered on the Hoon side with `~/` sigfas hints and on the C side in `tree.c` with the expected prototypes.  The initial call is made to the `u3w` function with a `u3_noun` input.  This routine is responsible for unpacking the result via the input addresses and providing some error checks.  It then calls the `u3q` or `u3k` routine (`u3k` being more for internal jets, `u3q` for newly-developed jets).

For instance, let's look at the jet code for `++add`.  The Hoon code is straightforward if tendentious:

```hoon
|%
+|  %math
++  add
  ~/  %add
  |=  [a=@ b=@]  ^-  @
  ?:  =(0 a)  b
  $(a (dec a), b +(b))
```

The C code is obscure and robust:

```c
u3_noun u3qa_add(u3_atom a, u3_atom b) {
  if ( _(u3a_is_cat(a)) && _(u3a_is_cat(b)) ) {
    c3_w c = a + b;

    return u3i_words(1, &c);
  } else if ( 0 == a ) {
    return u3k(b);
  } else {
    mpz_t a_mp, b_mp;

    u3r_mp(a_mp, a);
    u3r_mp(b_mp, b);

    mpz_add(a_mp, a_mp, b_mp);
    mpz_clear(b_mp);

    return u3i_mp(a_mp);
  }
}

u3_noun u3wa_add(u3_noun cor) {
  u3_noun a, b;

  if ( (c3n == u3r_mean(cor, u3x_sam_2, &a, u3x_sam_3, &b, 0)) ||
       (c3n == u3ud(a)) ||
       (c3n == u3ud(b) && a != 0) ) {
    return u3m_bail(c3__exit);
  } else {
    return u3qa_add(a, b);
  }
}
```

The conventional entry point is in the `u3wa_add` function, which checks for sample compatibility from the `u3_noun`.  The execution path then runs `u3wa_add → u3qa_add` with the values at sample addresses `2` and `3`.  The `u3q` function operates on the atoms extracted at the addresses indicated in the `u3_noun`.  (You must have your tree addressing down pat to write jets!)

Three cases must be dealt with by `u3qa_add`:

1.  The atoms fit in 31 bits and can be added directly (direct atoms).
2.  `a` is zero.
3.  The atoms take more than 31 bits and need explicit handling.  If the atom doesn't fit in 31 bits, then all the bytes must be handled using `mpz_add` instead.  (This is a function for handling arbitrary-precision addition from the [GNU MP](http://web.mit.edu/gnu/doc/html/gmp_2.html) library.)

    What does `u3a_is_cat` tell us?  It's a test for whether an atom fits in 31 bits or not (and thus is compound or simple).

```c
#define u3a_is_cat(som) (((som) >> 31) ? c3n : c3y)
```

A jet registration in the Hoon code tells the runtime to look for a function denoted by `%add`:

```c
static u3j_harm _141_one_add_a[] = { {".2", u3wa_add, c3y}, { } };
static u3j_core _141_one_d[] = { { "add", 7, _141_one_add_a, 0, _141_one_add_ha } };
```

Other components of the names are conventions used to identify the axis of the arm in the core (`+2`) and where in the jet system to locate the corresponding function.

Jets were originally quite controversial (and, I suppose, still are in some circles).  Jets have, however, been adopted into other languages because they allow you to design a language that can gracefully upgrade and degrade without altering the core program state:

> But why would you want such a thing? Because it gives a pathway for the state of the entire system to be a portable value, with no impure escape hatches. With no FFI or escape hatches to purity, your system can be an inspectable value which contains all of a user's programs and data forever, forward and backward compatible between interpreters.

Indeed,

> The jet has been the one thing about the Urbit system which has been copied by other systems. David Barbour's [Awelon][awelon] knows them as "accelerators" and Blockstream's [Simplicity][simplicity] adds Jets to a language much like [Charity][charity].

- Reading:  [Tlon Corporation, "`u3`:  Noun Processing in C"](https://github.com/urbit/urbit/blob/master/doc/spec/u3.md)
- Reading:  [Tlon Corporation, "Writing Jets"](https://urbit.org/docs/tutorials/vere/jetting/)
- Reading: [`xkpastel`, "Are Jets a Good Idea?" (Lambda the Ultimate)](http://lambda-the-ultimate.org/node/5482)


##  The Evolution of Nock

![](../img/39-header-pluto-1.png){: width=100%}

Nock cools towards absolute zero because stable is better than perfect.

Let's compare how Nock has evolved to this point.  We leave out definitions and focus on the rules, as the definitions change only very slightly over time.  (Notably, `^` hat/ket is the increment of an atom until the later substitution of `+` lus.)

The earliest Nock specification I have been able to locate is Nock 13K from March 2008.  The current version is 4K.  We consider the evolution of Nock over the years below.

**Nock 13K** (March 8, 2008):

```nock
*(a 0 b c)   => *(*(a b) c)
*(a 0 b)     => /(b a)
*(a 1 b)     => (b)
*(a 2 b)     => **(a b)
*(a 3 b)     => &*(a b)
*(a 4 b)     => ^*(a b)
*(a 5 b)     => =*(a b)
*(a 6 b c d) => *(a 2 (0 1) 2 (1 c d) (1 0) 2 (1 2 3) (1 0) 4 4 b)
*(a b c)     => (*(a b) *(a c))
*(a)         => *(a)
```

- Source:  [Tlon Corporation, "Nock 13K"](https://github.com/urbit/archaeology/blob/0b228203e665579848d30c763dda55bb107b0a34/Spec/nock/13.txt)

**Nock 12K** (March 28, 2008):

```nock
*(a (b c) d) => (*(a b c) *(a d))
*(a 0 b)     => /(b a)
*(a 1 b)     => (b)
*(a 2 b c)   => *(*(a b) c)
*(a 3 b)     => **(a b)
*(a 4 b)     => &*(a b)
*(a 5 b)     => ^*(a b)
*(a 6 b)     => =*(a b)

*(a 7 b c d) => *(a 3 (0 1) 3 (1 c d) (1 0) 3 (1 2 3) (1 0) 5 5 b)
*(a 8 b c)   => *(a 2 (((1 0) b) c) 0 3)
*(a 9 b c)   => *(a c)
```

- Source:  [Tlon Corporation, "Nock 12K"](https://github.com/urbit/archaeology/blob/0b228203e665579848d30c763dda55bb107b0a34/Spec/nock/12.txt)

**Nock 11K** (May 25, 2008):

```nock
*(a (b c) d) => (*(a b c) *(a d))
*(a 0 b)     => /(b a)
*(a 1 b)     => (b)
*(a 2 b c d) => *(a 3 (0 1) 3 (1 c d) (1 0) 3 (1 2 3) (1 0) 5 5 b)
*(a 3 b)     => **(a b)
*(a 4 b)     => &*(a b)
*(a 5 b)     => ^*(a b)
*(a 6 b)     => =*(a b)

*(a 7 b c)   => *(a 3 (((1 0) b) c) 1 0 3)
*(a 8 b c)   => *(a c)
```

- Source:  [Tlon Corporation, "Nock 11K"](https://github.com/urbit/archaeology/blob/0b228203e665579848d30c763dda55bb107b0a34/Spec/nock/11.txt)

**Nock 10K** (September 15, 2008):

```nock
*[a [b c] d] => [*[a b c] *[a d]]
*[a 0 b]     => /[b a]
*[a 1 b]     => [b]
*[a 2 b c d] => *[a 3 [0 1] 3 [1 c d] [1 0] 3 [1 2 3] [1 0] 5 5 b]
*[a 3 b]     => **[a b]
*[a 4 b]     => &*[a b]
*[a 5 b]     => ^*[a b]
*[a 6 b]     => =*[a b]
*[a]         => *[a]
```

- Source:  [Tlon Corporation, "Nock 10K"](https://github.com/urbit/archaeology/blob/0b228203e665579848d30c763dda55bb107b0a34/Spec/nock/10.txt)

**Nock 9K**:

```nock
*[a 0 b]          /[b a]
*[a 1 b]          b
*[a 2 b c d]      *[a 3 [0 1] 3 [1 c d] [1 0] 3 [1 2 3] [1 0] 5 5 b]
*[a 3 b]          **[a b]
*[a 4 b]          ?*[a b]
*[a 5 b]          ^*[a b]
*[a 6 b]          =*[a b]
*[a [b c] d]     => [*[a b c] *[a d]]
```

Note that none of the compositional rules are yet present.

- Source:  [Curtis Yarvin, "Maxwell's Equations of Software (Nock)"](https://moronlab.blogspot.com/2010/01/nock-maxwells-equations-of-software.html)
- Source:  [Tlon Corporation, "Nock 9K"](https://github.com/urbit/archaeology/blob/0b228203e665579848d30c763dda55bb107b0a34/Spec/nock/9.txt)

**Nock 8K*:

```nock
*[a 0 b]          /[b a]
*[a 1 b]          b
*[a 2 b c]        *[*[a b] *[a c]]
*[a 3 b]          ?*[a b]
*[a 4 b]          ^*[a b]
*[a 5 b]          =*[a b]
*[a 6 b c d]      *[a 2 [0 1] 2 [1 c d] [1 0] 2 [1 2 3] [1 0] 4 4 b]
*[a 7 b c]        *[a 2 b 1 c]
*[a 8 b c]        *[a 7 [7 b [0 1]] c]
*[a 9 b c]        *[a 8 b 2 [[7 [0 3] d] [0 5]] 0 5]
*[a 10 b c]       *[a 8 b 8 [7 [0 3] c] 0 2]
*[a 11 b c]       *[a 8 b 7 [0 3] c]
*[a 12 b c]       *[a [1 0] 1 c]
```

- Source:  [Curtis Yarvin, "Watt: A Self-Sustaining Functional Language"](https://github.com/cgyarvin/urbit/blob/900ef3b8ffc4a7245b74b816566ad23051a371b1/Spec/watt/sss10.tex)
- Source:  [Tlon Corporation, "Nock 8K"](https://github.com/urbit/archaeology/blob/0b228203e665579848d30c763dda55bb107b0a34/Spec/nock/8.txt)

**Nock 7K* (c. August 2013):

```nock
*[a 0 b]          /[b a]
*[a 1 b]          b
*[a 2 b c]        *[*[a b] *[a c]]
*[a 3 b]          ?*[a b]
*[a 4 b]          ^*[a b]
*[a 5 b]          =*[a b]

*[a 6 b c d]      *[a 2 [0 1] 2 [1 c d] [1 0] 2 [1 2 3] [1 0] 4 4 b]
*[a 7 b c]        *[a 2 b 1 c]
*[a 8 b c]        *[a 7 [[7 [0 1] b] 0 1] c]
*[a 9 b c]        *[a 7 c 0 b]
*[a 10 b c]       *[a c]
*[a 10 [b c] d]   *[a 8 c 7 [0 3] d]
```

- Source:  [Curtis Yarvin, "Watt: A Self-Sustaining Functional Language"](https://github.com/cgyarvin/urbit/blob/900ef3b8ffc4a7245b74b816566ad23051a371b1/Spec/watt/sss10.tex)
- Source:  [Tlon Corporation, "Nock 7K"](https://github.com/urbit/archaeology/blob/0b228203e665579848d30c763dda55bb107b0a34/Spec/nock/7.txt)

**Nock 6K* (c. October 2018):

```nock
*[a 0 b]          /[b a]
*[a 1 b]          b
*[a 2 b c]        *[*[a b] *[a c]]
*[a 3 b]          ?*[a b]
*[a 4 b]          +*[a b]
*[a 5 b]          =*[a b]

*[a 6 b c d]      *[a 2 [0 1] 2 [1 c d] [1 0] 2 [1 2 3] [1 0] 4 4 b]
*[a 7 b c]        *[a 2 b 1 c]
*[a 8 b c]        *[a 7 [[0 1] b] c]
*[a 9 b c]        *[a 7 c 0 b]
*[a 10 b c]       *[a c]
*[a 10 [b c] d]   *[a 8 c 7 [0 2] d]
```

- Source:  [Tlon Corporation, "Nock 6K"](https://github.com/urbit/archaeology/blob/0b228203e665579848d30c763dda55bb107b0a34/Spec/nock/6.txt)

**Nock 5K* (c. November 2013):

```nock
*[a 0 b]          /[b a]
*[a 1 b]          b
*[a 2 b c]        *[*[a b] *[a c]]
*[a 3 b]          ?*[a b]
*[a 4 b]          +*[a b]
*[a 5 b]          =*[a b]

*[a 6 b c d]      *[a 2 [0 1] 2 [1 c d] [1 0] 2 [1 2 3] [1 0] 4 4 b]
*[a 7 b c]        *[a 2 b 1 c]
*[a 8 b c]        *[a 7 [[7 [0 1] b] 0 1] c]
*[a 9 b c]        *[a 7 c 2 [0 1] 0 b]
*[a 10 [b c] d]   *[a 8 c 7 [0 3] d]
*[a 10 b c]       *[a c]
```

- Source:  [Tlon Corporation, "Nock 5K"](https://github.com/urbit/archaeology/blob/0b228203e665579848d30c763dda55bb107b0a34/Spec/nock/5.txt)

**Nock 4K*:

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

- Source:  [Tlon Corporation, "Nock 4K"](https://urbit.org/docs/tutorials/nock/definition/)

"Nock 10 was added during the transition from Nock 5K to Nock 4K and is an optimization which makes efficient modifications to a Nock data structure" (Elliot Glaysher).

Compare Nock 8K to 4K:

- Rules Zero through Five are unchanged, except for the substitution of `+` for `^`.  (We call these the essential rules.)
- Rules Six through the end are structured substantially differently but have some correspondences.  They do the same things but are redefined by 4K in terms of only essential rules.
    - 8K Rule Six = 4K Rule Six, `if`/`then`/`else`
    - 8K Rule Seven = 4K Rule Seven, function composition
    - 8K Rule Eight = 4K Rule Eight, stack push/variable declaration
    - 8K Rule Nine = 4K Rule Nine, calling convention/compute against current subject
    - 8K Rule Ten, consolidate for reference equality
    - 8K Rule Eleven, arbitrary hint to system
    - 8K Rule Twelve, jet acceleration label
    - 4K Rule Ten, replace value in subject
    - 4K Rule Eleven, hint (static or dynamic)

You can see a lot of shuffling in the early versions of Nock, rather appropriate for a "warmer" system.  I rather suspect that even 13K was too optimistic for really getting Nock straight, but as the Precepts state, “standardization is better than perfection.”

What's in store for Nock?  Only four more revisions can be made, so choices and changes must be very careful.

One faction argues that the Nock combinator calculus is not a good choice for a fully fundamental language representation.  They take issue with the heuristic Rules Six through Ten and criticize the ability of any Nock interpreter to actually simplify the call stack:

> I traced through running `(add 2 2)`. When you count up the work that goes into dispatching a single function call, the current nock interpreter does the stack and program counter management overhead to perform 23 internal bytecodes, which allocates 7 cons cells, increases the refcount of 12 memory locations, decreases the refcount of 4 nouns (which may affect other memory locations because refcount decrement is recursive), and performs 3 arbitrary tree walks. We do this even if we are calling a jet: since jet registration is a stateful side effect, we must perform all the tree math to first get the noun which has the jet registration. And the number of arbitrary binary tree traversals and cons cell allocations grow with the number of arguments passed to the function.

These developers have proposed Skew (née Uruk) as a Nock 3K.  Skew is an enriched lambda calculus that can encode the unenriched lambda calculus and handle jets and virtualization.  The specification eliminates the use of natural numbers as well:

```nock
*(K x y)                        x
*(x y)                          (*x y)
*(x y)                          (x *y)
*(S x y z)                      (x z (y z))
*(E^n t f x1 … xn)              (f x1 … xn)
*(W a s k e w (x y))            (a x y)
*(W a s k e w S)                s
*(W a s k e w K)                k
*(W a s k e w E)                e
*(W a s k e w W)                w
```

These rules apply sequentially until nothing further can result.

I started composing a breakdown doc like we had for the Nock 4K rules, but you should really just read the current specs for Skew if you're interested.  The parts I'd like to particular draw out for you are:

- the $S$ Substitution combinator;
- the $K$ Konstant combinator;
- the $E$ Enhance jet combinator; and
- the $W$ sWitch statements.

A real Skew interpreter exists:  Skew has been implemented on the `uruk-skew` branch of the `urbit` GitHub repo.  Speed tests for Skew as proposed are promising, but the verdict is still out on whether such a radical break in Nock will be followed through.

> I don't know that SKEW is perfect, but it's a much better contender for "tiny and diamond-perfect" than Nock 4K+ is: $SK$, $E$ and $W$ each directly addresses one of the requirements and each appear to be the simplest thing which could address them, and is thus much closer to the Nock ideal of "tiny and diamond-perfect" than previous Nocks. At 10 lines of reduction rules, it is roughly a third of the length of the Nock 4K spec, and half the SKEW spec is an explicitly unrolled switch statement. And as an extension of the unenriched lambda calculus, it can act as a compile target for the pure parts of any functional language which compiles down to the lambda calculus (any pure primops needed can be written as jets), while Nock 4K is tied to the semantics of its corresponding frontend language.

Most intriguingly, Skew fractures our naïve conception of _the_ Nock into _a_ Nock.  In other words, there is a field of possible final diamond kernels which are aligned with Martian principles.  Whatever replaces Nock 4K someday will have to be a legitimate improvement moving the system towards thermodynamic cooling.

- Reading: [Benjamin `~siprel` & Elliot Glaysher `~littel-ponnys`, "SKEW"](https://github.com/urbit/urbit/blob/skew/pkg/hs/urbit-skew/skew.md)
- Optional Reading: [`urbit` `uruk-skew` branch](https://github.com/urbit/urbit/tree/uruk-skew)
