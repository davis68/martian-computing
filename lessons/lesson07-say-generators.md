#   `%say` Generators

![](../img/07-header-apollo-1.png)

##  Learning Objectives

-   Create a `%say` generator.


##  Generators

Recall that a generator is a nonpersistent computation.  You previously worked with naked generators, but there were other kinds hinted at then.  The next of these is a `%say` generator.  This has, over and beyond a naked generator, metadata including `context` for the generator.

In brief, a naked generator knows about nothing except libraries explicitly imported, not even Arvo.  (Think of it as a C program with no `#include` statements.)  What we may call "clad" generators do know about Arvo and are able to leverage information from and about the operating system in performing their calculations.

A basic `%say` generator looks like this:

```hoon
:-  %say
|=  *
:-  %noun
(sub 1.000 1)
```

- `:-` composes a cell
- `%` in front of text indicates a `@tas`-style constant
- `*` is a mold matching any data type, atom or cell

This generator can accept any input (`*`) or none at all.  It returns, in any case, `999`.

To match a particular mold, you can specify from this table, with atoms expanding to the right as auras.

| Shorthand | Mold |
| --------- | ---- |
| `*` | noun |
| `@` | atom |
| `^` | cell |
| `?` | loobean |
| `~` | null |


The generator itself consists of a cell `[%say hoon]`, where `hoon` is the rest of the code.  The `%say` metadata tag indicates to Arvo what the expected structure of the generator is _qua_ `%say` generator.

In general, a `%say` generator doesn't need a sample (input arguments) to complete:  Arvo can elide that if necessary[.](https://www.youtube.com/watch?v=iYdk1BsAI2M)  <!-- egg -->

More generally, a `%say` generator

The `sample` should be a 3-tuple:  `[[now eny beak] ~[unnamed arguments] ~[named arguments]]`.

> `now` is the current time.  `eny` is 512 bits of entropy for seeding random number generators.  `beak` contains the current ship, desk, and case.

How do we leave things out?

> Any of those pieces of data could be omitted by replacing part of the noun with * rather than giving them faces. For example, `[now=@da * bec=beak]` if we didn't want eny, or `[* * bec=beak]` if we only wanted `beak`.

### Now

In Dojo, you can always produce the current time as an atom using `now`.  This is a Dojo convenience, however, and we need to bind `now` to a face if we want to use it inside of a generator.

Time in Urbit will be covered in Zuse.

### Entropy

![](../img/07-header-apollo-2.png)

What is _entropy_?  [Computer entropy](https://en.wikipedia.org/wiki/Entropy_%28computing%29) is a hardware or behavior-based collection of device-independent randomness.  For instance, "The Linux kernel generates entropy from keyboard timings, mouse movements, and IDE timings and makes the random character data available to other operating system processes through the special files `/dev/random` and `/dev/urandom`."

For instance, run `cat /dev/random` on a Linux box and observe the output.  You'll need to run `Ctrl`+`C` to exit to the prompt.  Run it again, and again.  You'll see that the store of entropy diminishes rather quickly because it is thrown away once it is used.

(And you thought that random number generators just used the time as a seed!)

### Beak

>Paths begin with a piece of data called a `beak`. A beak is formally a `(p=ship q=desk r=case)`; it has three components, and might look like `/~dozbud-namsep/home/11`.

You can get this information in Dojo by typing `%`.

##  Other Arguments

The full sample prototype for a `%say` generator looks like `[[now, eny, beak] [unnamed arguments] [named arguments]]`.

You see a similar pattern in languages like Python, which permits (required) unnamed arguments before named "keyword arguments".

### Unnamed Arguments

By "unnamed" arguments, we really mean _required_ arguments; that is, arguments without defaults.  We stub out information we don't want with the empty noun `*`:

```hoon
|=  [* [a=@ud b=@ud c=@ud ~] ~]
(add (mul a b) c)
```

(You can use this in Dojo as well:

```hoon
=f |=  [* [a=@ud b=@ud c=@ud ~] ~]
(add (mul a b) c)
(f [* ~[1 2 3] ~])
```

.)

Note that we retain the terminating `~` since the expected sample is a list.

### Named Arguments

We can incorporate optional arguments although without default values (i.e., the default value is always type-appropriate `~`).

```hoon
|=  [* ~ [val=@ud ~]]
(add val 2)
```

To use it:

```hoon
+g =val 4
```

Since the default value is `~`, if you are testing for the presence of named arguments you should test against that value.

Note that, in all of these cases, you are writing a gate `|=` bartis which accepts `[* * ~]` or the like as sample.  Dojo (and Arvo generally) recognizes that `%say` generators have a special format and parse the command-line form into appropriate form for the gate itself.

- Reading: [Tlon Corporation, "Generators"](https://urbit.org/docs/hoon/hoon-school/generators/), sections "%say Generators", "%say generators with arguments", "Arguments without a cell"

##  Worked Examples

### Xenotation

[Tic xenotation](http://hyperstition.abstractdynamics.org/archives/003538.html) is a way of writing any number using a minimal number of characters.  Each number is broken down into its prime factors and

For instance, the integers 2–15 in xenotation take the form:

| Number | Tic Xenotation |
| ------ | -------------- |
|      2 | $\cdot$ (first prime) |
|      3 | $(\cdot)$ (second prime) |
|      4 | $\cdot\cdot$ (first prime times first prime) |
|      5 | $((\cdot))$ (third prime) |
|      6 | $\cdot(\cdot)$ (first prime times second prime) |
|      7 | $(\cdot\cdot)$ (fourth prime) |
|      8 | $\cdot\cdot\cdot$ (first prime times first prime times first prime) |
|      9 | $(\cdot)(\cdot)$ (second prime times second prime) |
|     10 | $\cdot((\cdot))$ (first prime times third prime) |
|     11 | $(((\cdot)))$ (fifth prime) |
|     12 | $\cdot\cdot(\cdot)$ (first prime times first prime times second prime) |
|     13 | $(\cdot(\cdot))$ (sixth prime) |
|     14 | $\cdot(\cdot\cdot)$ (first prime times fourth prime) |
|     15 | $(\cdot)((\cdot))$ (second prime times third prime) |

What does 16 look like?

For historical reasons, I broke this code up into a `%say` generator `gen/xeno.hoon` and a library file `lib/primes.hoon` with the `++xenotate` arm in `primes`.  (This is older Hoon code written when I was first learning Hoon, and although everything is accurate and performative, I don't consider it to be a particularly elegant or efficient implementation, particularly of the prime sieve.  `++xenotate` is also profligate with recalculating prime lists.)

**`xeno.hoon`**:

```hoon
/+  primes
:-  %say
|=  [[* eny=@uv *] [n=@ud ~] ~]
:-  %noun
(xenotate:primes n)
```

**`primes.hoon`**:

```hoon
|%
::
:: Decompose into prime factors in ascending order.
::
++  prime-factors
  |=  n=@ud
  %-  sorter
  ?:  =(n 1)  ~[n 1]
  =+  [i=0 m=n primes=(primes-to-n n) factors=*(list @ud)]
  |-  ^+  factors
  ?:  =(i (lent primes))
    [factors]
  ?:  =(0 (mod m (snag i primes)))
    $(factors [`@ud`(snag i primes) factors], m (div m (snag i primes)), i i)
  $(factors factors, m m, i +(i))
::
:: Find prime factors in ascending order.
::
++  primes-to-n
  |=  n=@ud
  %-  dezero
  ?:  =(n 1)  ~[~]
  ?:  =(n 2)  ~[2]
  ?:  =(n 3)  ~[3]
  =+  [i=0 cands=(siev (div n 2)) factors=*(list @ud)]
  |-  ^+  factors
  ?:  =(i (lent cands))
    ?:  =(0 (lent (dezero factors)))
      ~[n]
    factors
  $(factors [`@ud`(filter cands n i) factors], i +(i))
::
:: Strip off matching modulo-zero components, (mod n factor)
::
++  filter
  |*  [cands=(list) n=@ud i=@ud]
  ?:  =((mod n (snag i `(list @ud)`cands)) 0)
    [(snag i `(list @ud)`cands)]
  ~
::  Find primes by the sieve of Eratosthenes
++  siev
  |=  n=@ud
  %-  dezero
  =+  [i=2 end=n primes=(gulf 2 n)]
  |-  ^+  primes
  ?:  (gth i n)
    [primes]
  $(primes [(clear (sub i 2) i primes)], i +(i))
:: wrapper to remove zeroes after sorting
++  dezero
  |=  seq=(list @)
  =+  [ser=(sort seq lth)]
  `(list @)`(skim `(list @)`ser pos)
++  pos
  |=  a=@
  (gth a 0)
:: wrapper sort---does NOT remove duplicates
++  sorter
  |=  seq=(list @)
  (sort seq lth)
:: replace element of c at index a with item b
++  nick
  |*  [[a=@ b=*] c=(list @)]
  (weld (scag a c) [b (slag +(a) c)])
:: zero out elements of c starting at a modulo b (but omitting a)
++  clear
  |*  [a=@ud b=@ud c=(list)]
  =+  [j=(add a b) jay=(lent c)]
  |-  ^+  c
  ?:  (gth j jay)
    [c]
  $(c [(nick [j 0] c)], j (add j b))
::
:: Xenotate the number per
::   http://hyperstition.abstractdynamics.org/archives/003538.html
::
++  xenotate
  |=  n=@ud
  =+  [i=0 factors=(prime-factors n)]
  =+  [primes=(siev n) xeno=*tape]
  |-  ^+  xeno
  ?:  =(i (lent factors))
    xeno
  ?:  =(2 (snag i factors))
    $(xeno (weld "·" xeno), i +(i))
  =+  [pi=u.+:(find ~[(snag i factors)] primes)]
  =+  [inner=(xenotate +(pi))]
  $(xeno (weld xeno (weld (weld "(" inner) ")")), i +(i))
--
```

### Documentation Examples

The following Hoon Workbook examples walk you line-by-line through several `%say` generators of increasing complexity.

The traffic light example is furthermore an excellent prelude to our entrée to Gall.

- Reading: [Tlon Corporation, "Hoon Workbook:  Digits"](https://web.archive.org/web/20210315002509/https://urbit.org/docs/tutorials/hoon/workbook/digits/)
- Reading: [Tlon Corporation, "Hoon Workbook:  Magic 8-Ball"](https://web.archive.org/web/20210315002732/https://urbit.org/docs/tutorials/hoon/workbook/eightball/)
- Reading: [Tlon Corporation, "Hoon Workbook:  Traffic Light"](https://web.archive.org/web/20210315032448/https://urbit.org/docs/tutorials/hoon/workbook/traffic-light/)

![](../img/07-header-apollo-3.png)
