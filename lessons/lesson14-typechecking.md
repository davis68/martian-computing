#   Type in Urbit

![](../img/14-header-galileo-1.png)

##  Learning Objectives

- Understand how type inference and type checking takes place.
- Build more complicated bunt and mold structures.


##  Molds

The overarching model for type in Urbit is the _mold_, which is essentially an enforceable type signature.  "A mold is an idempotent function that coerces a noun to be of a specific type or crashes."

Molds are used to check type or produce certain kinds of types, whereas mold builders are used to produce suitable molds.  For instance, `list` is in fact a mold builder:  `(list @ud)` produces a mold via a gate `list` which acts as a mold builder.

Molds are the primary way for enforcing and processing type structure in Urbit.

![](../img/14-header-galileo-2.png)

There are some standard mold operations:

- Each mold has a characteristic **bunt**:  "The placeholder value is sometimes called a bunt value. The bunt value is determined by the input type; for atoms, `@`, the bunt value is `0`."  You can get the bunt using [`*` tar or `^*` kettar](https://urbit.org/docs/reference/hoon-expressions/rune/ket/#kettar).

    "We do often bunt a mold: create a default or example noun. Logically, we bunt by passing the mold its default argument."  (Whitepaper)

- You can **clam** a mold:  this means to produce a conversion gate to the target mold.  See [`^:` ketcol](https://urbit.org/docs/reference/hoon-expressions/rune/ket/#ketcol).

- A **fish** tests whether a value properly nests within a given mold.  You can check this using [`?=` wuttis](https://urbit.org/docs/reference/hoon-expressions/rune/wut/#wuttis); note that this currently fails for recursive mold builders like `list`.

- You can **whip** a mold:  convert a value to the target mold.

Aside from bunt, it is uncommon to see these terms used today, preferring just the description of the operation.

(For comparison, please look at this circa-2016 doc excerpt:

> **clam**: a tile reduction. A clam just produces a gate which executes a whip to the given tile (e.g. it produces a closure which remembers the tile you give it, as passes that to the whip reduction when it is called)

The terminology and docs have come a long way.  "Tile" = "mold.")

Mold builders can work well applied as functions even if they fail via aura application:

```hoon
> `(list @t)`~[100 101 102]
/~zod/home/~2020.4.7..06.13.55..d061/sys/vane/ford:<[4.820 18].[4.820 59]>
mint-nice
nest-fail
ford: %slim failed:
ford: %ride failed to compute type:
> ((list @t) ~[100 101 102])
<|d e f|>
```

- Reading: [Tlon Corporation, "Molds"](https://urbit.org/docs/hoon/hoon-school/molds/)
- Reading: [Tlon Corporation, "1c Molds and Mold Builders"](https://urbit.org/docs/reference/library/1c/)
- Reading: [Tlon Corporation, "Type Checking and Type Inference"](https://urbit.org/docs/hoon/hoon-school/type-checking-and-type-inference/)
- Reading: [Tlon Corporation, "Structures and Complex Types"](https://urbit.org/docs/hoon/hoon-school/structures-and-complex-types/)

I recommend that you review section Vases in Cores as well.


##  Dry Gates

![](../img/14-header-galileo-3.png)

> A dry gate (also simply a gate) is the kind that you're already familiar with by now: a one-armed core with a sample. A wet gate is also a one-armed core with a sample, but there is a difference. With a dry gate, when you pass in an argument and the code gets compiled, the type system will try to cast to the type specified by the gate; if you pass something that does not fit in the specified type, for example a cord instead of a cell you will get a nest failure. On the other hand, when you pass arguments to a wet gate, their types are preserved and type analysis is done at the definition site of the gate rather than the call site.

In other words, a dry gate requires the argument type to match.  A wet gate lets the arguments be "coerced" for internal purposes.  However, dry gates can express type variance in several ways.

Let us consult [La Wik](https://en.wikipedia.org/wiki/Covariance_and_contravariance_%28computer_science%29) on the subject of polymorphism:

> Within the type system of a programming language, a typing rule or a type constructor is:
>
> - _covariant_ if it preserves the ordering of types (≤), which orders types from more specific to more generic;
> - _contravariant_ if it reverses this ordering;
> - _bivariant_ if both of these apply;
> - _invariant_ or _nonvariant_ if not variant.

Compare with the Urbit whitepaper:

> There are two forms of polymorphism: variance and genericity. In Hoon this choice is per arm.  A dry arm uses variance; a wet arm uses genericity.

All of the gates we have made thus far using `|=` bartis are dry gates.  In this case, we are simply checking if the payload being employed is compatible (what auras and molds do).  "Dry gates", therefore, are called as if they were typical functions in most programming languages.

Arguments made to dry gates must nest.  More generally, dry cores must have nested types.  (This differs from a language like Python, in which you can rather freely cast from one type to another, as `int` to `float`.  `@ud` and `@rs` are fundamentally different auras in Hoon, although `sun` can interconvert.)

> With a dry gate, when you pass in an argument and the code gets compiled, the type system will try to cast to the type specified by the gate; if you pass something that does not fit in the specified type, for example a `cord` instead of a `cell` you will get a nest failure.

![](../img/14-header-galileo-4.png)

> The type check for each arm in a dry core can be understood as implementing a version of the “Liskov substitution principle.”  The arm works for some (originally defined) payload type `P`.  Payload type `Q` nests under `P`.  Therefore the arm works for `Q` as well, though for type inference purposes the payload is treated as a `P`.  The inferred type of the arm is based on the assumption that it's evaluated with a subject type exactly like that of its original parent core—i.e., whose payload is of type `P`.

HOWEVER, dry cores can differ in their variance models.

| Behavior | Metal | Interpretation | Example |
| -------- | ----- | -------------- | ------- |
| Invariant | `%gold` | Read-write payload | "when type-checking against a gold core, the target payload cannot vary at all in type. Consequently, it is type-safe to modify every part of the payload: gold cores have a read-write payload." |
| Bivariant | `%lead` | Opaque payload | "There is no restriction on which payload types nest. That means, among other things, that the payload type of a lead core is both covariant and contravariant ('bivariant')." |
| Covariant | `%zinc` | Write-only sample | "The sample of a zinc core is read-only. That means, among other things, that zinc cores cannot be used for function calls." |
| Contravariant | `%iron` | Read-only sample | "Iron gates are particularly useful when you want to pass gates (having various payload types) to other gates." |

In practice, gold and iron cores are commonly seen; I've observed far fewer zinc and lead gates in the wild.  Gates constructed with `|` bar runes can be converted using some of the `&` pam runes.

- Reading: [Tlon Corporation, "Type Polymorphism"](https://urbit.org/docs/hoon/hoon-school/type-polymorphism/), sections "Dry Cores" and "The Four Kinds of Cores"
- Reading: [Tlon Corporation, "Advanced Types"](https://urbit.org/docs/reference/hoon-expressions/advanced/), sections on dry gates in "`%core` Advanced Polymorphism"

We will discuss wet gates in Polymorphism.

![](../img/14-header-galileo-5.png)

_The Moon is made of cheese, and cheese is made from mold.  These are Galileo's drawings of the Moon from his early telescope experiments._
