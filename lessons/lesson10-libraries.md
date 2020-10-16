#   Libraries

![](../img/10-header-stars-3.png)

##  Learning Objectives

- Create a library in `lib/` and call it using `/+`.
- Write unit tests for the library.
- Employ strategies for nested loops.
- Compose Hoon that adheres to the Tlon Hoon style guide.
* Produce a library.


##  Libraries

What makes something a library?  A library, or module, or package, is a collection of optional yet useful code which coherently carries out some task.

For our purposes, a library is basically a battery, no payload.  It's typically constructed with a `|%` barcen rune and stored in the `lib/` folder.

The Ford rune `/+` faslus imports a Hoon file into the subject from `lib/` in the current desk.  (Because of the way Ford and the subject interact, you can't execute most of these things in the Dojo.  I recommend making a minimal generator to import and test your functions.)

```hoon
/+  bip39
:-  %say
|=  [[* eny=@uv *] ~ ~]
:-  %noun
(to-seed:bip39 "words" "more-words")         ```

Use `*` in front of the name to import the library without a face.

```hoon
/+  *bip39
:-  %say
|=  [[* eny=@uv *] ~ ~]
:-  %noun
(to-seed "words" "more-words")
```

A few other Ford runes manage builds and dependencies from other parts of Arvo; more in Ford 1.

Urbit does not at the time of writing have a package management system (August 2020):  there's not enough userspace code to require it yet, and everything else new has just come to live in the kernel, thereby inheriting the mantle of obsessive refinement.

### Library Composition

Any file in `lib/` can be imported using `/+` faslus.  It should be structured as a core, likely with `|%` barcen.  Here's a more complex example of a library:

```hoon
::
::::  Vector type in single-precision floating-point @rs
  ::
|%
++  lvs
  ^|
  ~%  %lvs  ..is  ~
  |_  r/$?($n $u $d $z)   :: round nearest, round up, round down, round to zero
  ::
  ::    Zeroes
  ++  zeros
    ~/  %zeros
    |=  n=@ud  ^-  @lvs
    ~_  leaf+"lagoon-fail"
    =/  nan  0xffff.ffff
    `@lvs`(not 5 +(n) (rap 5 ~[(fil 5 n nan) (not 5 1 n)]))
  ::
  ::    Ones
  ++  ones
    ~/  %ones
    |=  n=@ud  ^-  @lvs
    ~_  leaf+"lagoon-fail"
    =/  one  (bit:rs [%f s=%.y e=-0 a=1])
    =/  not-one  (not 5 1 one)
    `@lvs`(not 5 +(n) (rap 5 ~[(fil 5 n not-one) (not 5 1 n)]))
  --
--
```

There are some new runes in there, of course, but pay attention to the `|%`/`++`/`--` structure overall.

(As an aside, `^|` ketbar adjusts type nesting to be contravariant; `~%` sigcen and `~/` sigfas are jet hints; and `~_` sigcab is an error annotation.)


##  Traps as Nested Loops

Consider a classic nested loop, as in C:

```c
uint i, j;
for ( i = 0; i < m; i++ ) {
  for ( j = 0; j < n; j++ ) {
    w += u[i] * v[j];
  }
}
```

Altogether, the code inside of these loops executes `m*n` times.

Naïvely, you may suppose that you can compose a nested loop as a trap inside of a trap, something like this:

```hoon
!:
|=  [m=@ud n=@ud]  ^-  @ud
  =/  i  1
  =/  j  1
  =/  w  0
  |-  ^-  @ud
    ?:  =(i n)  w
    |-  ^-  @ud
      ?:  =(j n)
        $(i +(i), j 0, w (add w (mul i j)))
      $(i i, j +(j), w (add w (mul i j)))
```

The problem is that traps have a named default subject `$` which generates and replaces the subject from the first trap.  This code fails because of confusion around `$`.

My preferred solution is to unroll the loop:  track the conditions under which each loop iteration terminates and compose a test to find those conditions.  For each test, associate a `$()` regeneration point.  It's a bit like rewriting a nested loop as a `while` loop in a procedural language like C or Python.

```hoon
=/  i  1
=/  j  1
|-
  =(i n)  w
  =(j n)  $(i +(i), j 0, w w)
  $(i i, j +(j), w (add w (mul (snag i u) (snag j v))))
```

Another solution is to "escape" the subject `$` with `^`:  `^$` skips the first match of the symbol `$` and thus triggers the outer trap.  This approach is used sometimes in kernel code.


##  Testing Code

Best coding practice recommends composing unit tests to verify the behavior of program components.  A good unit test tests one thing and one thing only.

The primary way to test code automatically is to use Ford's `+test` generator.  This scans for arms (that conventionally begin with `++test`) in the `tests/` folder at a path otherwise corresponding to the system path.  For instance, to run the unit tests for a particular library file:

```hoon
> +test /lib/number-to-words
OK      /lib/number-to-words/test-eng-us
```

(How can you list all of the files in `tests/` from inside of Urbit?)

In other words, the standard location for the unit tests for a file are at the same path _inside_ of the `tests/` directory.

Here is a complete unit test file, extracted from `tests/lib/numbers-to-words.hoon`:

```hoon
::  tests for number-to-words
::
/+  number-to-words, *test
::
|%
++  test-eng-us
  =+  eng-us:number-to-words
  ;:  weld
    %+  expect-eq
      !>  `(unit tape)``"zero"
      !>  (to-words 0)
  ::
    %+  expect-eq
      !>  `(unit tape)``"one"
      !>  (to-words 1)
  ::        We distinguish different aspects of the programming flaw based on their observational mode:

- A _failure_ refers to the observably incorrect behavior of a program. This can include segmentation faults, erroneous output, and erratic results.

- A _fault_ refers to a discrepancy in code that results in a failure.

- An _error_ is the mistake in human judgment or implementation that caused the fault. Note that many errors are latent or masked.

- A _latent_ error is one which will arise under conditions which have not yet been tested.

- A _masked_ error is one whose effect is concealed by another aspect of the program, either another error or an aggregating feature.

We casually refer to all of these as bugs.

An exception is a manifestation of unexpected behavior which can give rise to a failure, but some languages—notably Python—use exceptions in normal processing as well.

(If you have not encountered these concepts via dev/debugging yet, this is identical to the terminology we adopt when debugging.)


    %+  expect-eq
      !>  `(unit tape)``"twelve"
      !>  (to-words 12)
  ::
    %+  expect-eq
      !>  `(unit tape)``"one vigintillion"
      !>  (to-words (pow 10 63))
  ==
--
```

There are two library imports:  the library to test and `test` (with no namespace).  `test` contains two arms:  `++expect-eq` and `++expect-fail`[.](https://s3-us-west-1.amazonaws.com/vocs/map.html#)  <!-- egg -->

As you can see above, the expected structure of a testing file introduces a couple of new runes:  `;:` miccol and `%+` cenlus.

- `;:` allows us to run a binary function as if it were an $n$-ary function; that is, we can string together the whole following list against the `weld` function.  Since it doesn't take a specific number of runes, you have to terminate the running series with the digraph `==` tistis.
- `%+` calls a gate with a cell sample.  In this case, we use it to
- `!>` isn't new—you saw these in Cores when we talked about vases.  It wraps a noun in its type producing a vase.

Most of the time, `++expect-eq` is the only arm used.  `++expect-fail` works a bit differently:

```hoon
++  test-map-got  ^-  tang
  ;:  weld
    ::  Checks with non-existing key
    ::
    %-  expect-fail
      |.  (~(got by m-des) 9)
  ==
```

`|.` bardot is like `|-` barhep but defers evaluation instead.  Here we are using it to evaluate the expected failure later than compilation time.

- Optional Reading: [Tlon Corporation, "Unit Testing with Ford"](https://web.archive.org/web/20200614210451/https://urbit.org/docs/tutorials/hoon/test-sets/)

![](../img/10-header-stars-2.png)


##  Hoon Style

It's time for you to read and absorb the [authoritative Hoon style guide](https://urbit.org/docs/tutorials/hoon/style/).  All code you produce subsequently should hew to it, particularly the informal comments.  (It will take us a while yet in this course to get to the point where formal comments are worth the trouble.)

It's worth noting that I have a few minor quibbles on style:

1. Breathing comments feel backwards to me.
2. I think that trap resolutions `$()` should be differently indented to make the loop more legible (most of the time); i.e., there should be flexibility in this placement.
3. Trap bodies should be indented (rather than backstepping).  I admit this to be procedural recidivism on my part.

For instance, here are samples from some library code I have written, which adhere to different rules for making the `$` resolution legible and indent the trap bodies.

```hoon
  |-  ^-  @lvs
    ?:  =(count n)  (make w)
    =/  ul  (snag count uu)
    =/  vl  (snag count vv)
    =/  wl  `@rs`(sub:rs ul vl)
  $(count +(count), w (weld ~[wl] w))
```

```hoon
++  gauss-elimination
  |-  ^-  @lms
    ?:  (gth i mu)  `@lms`u
    ?:  (gth j mu)  $(i +(i), j 1, k k, u u)
    ?:  (gth k nu)  $(i i, j +(j), k k, u u)
    ?:  =(i j)      $(i i, j +(j), k k, u u)
    $(i i, j j, k +(k), u (set u j k (sub:rs (get u j k) (mul:rs (get u i k) (div:rs (get u j i) (get u i i))))))
```

(Note that the latter is a triple-nested code fragment.)

How would you rewrite these code snippets in fully-compliant style?

- Reading: [Tlon Corporation, "Hoon Style Guide"](https://urbit.org/docs/tutorials/hoon/style/)


##  A Word of Encouragement

> Don't embed fear in your code.  Don't design systems around your fear because you don't have confidence in your system.  Tools should motivate the mind, not subjugate it.  (Aaron Hsu)

![](../img/10-header-stars-1.png)
