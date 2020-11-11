#   `hoon.hoon`

![](../img/34-header-comet-0.gif){: width=100%}

##  Learning Objectives

-   Deep dive through `hoon.hoon`.


In this lesson, we will examine some other interesting aspects of `hoon.hoon` besides the parser.  `hoon.hoon` is relatively old code stylistically; its organization corresponds to the documentation in having chapters like [`4m: formatting functions`](https://urbit.org/docs/reference/library/4m/).

##  The Base Types of Hoon

![](../img/34-header-comet-1.gif){: width=100%}

The Hoon type system recognizes only a few core types.  `+$type` (formerly `$span`) encompasses important specific types for parsing and representing data in the ASTs.

```hoon
+$  type  $~  %noun                                 ::
          $@  $?  $noun                             ::  any nouns
                  $void                             ::  no noun
              ==                                    ::
          $%  {$atom p/term q/(unit @)}             ::  atom / constant
              {$cell p/type q/type}                 ::  ordered pair
              {$core p/type q/coil}                 ::  object
              {$face p/$@(term tune) q/type}        ::  namespace
              {$fork p/(set type)}                  ::  union
              {$hint p/(pair type note) q/type}     ::  annotation
              {$hold p/type q/hoon}                 ::  lazy evaluation
          ==                                        ::
```

These are:

- `noun`
- `void`
- `atom` with text aura
- `cell` of `+$type` and `+$type`
- `core` of environment `+$type` and `coil` mapping core name to `garb` (name, wet/dry, and variance), context, and chapters
- `face` of name wrapping `+$type`
- `fork` of `+$type`s
- `hint` annotating subject and `+$type`
- `hold` of subject `+$type` and continuation AST for lazy (deferred) evaluation

If there are other types you encounter in `hoon.hoon` which are opaque to you, consult `+$hoon` for a catalogue.


##  Prettyprinting

![](../img/34-header-comet-2.gif){: width=100%}

Prettyprinting is the process of rendering internal data in a legible way for the user or for other programs.  The `++ut` arm of the compiler in `hoon.hoon` provides prettyprinter support.

Hoon adopts a convention whereby any atom is uniquely determined by its representation; that is, `~.1`, `.1`, and `.~~~1` are all different floating-point numbers and it is easy to tell which kind.  There is no ambiguity in either parsing or printing these values.

To pretty-print an atom, the aura is of course taken into account.  Hoon supports a lot of this, but of course the Dojo stack contributes as well.

To pretty-print a value, Hoon generates a `+$plum`:

```hoon
+$  plum
  $@  cord
  $%  [%para prefix=tile lines=(list @t)]
      [%tree fmt=plumfmt kids=(list plum)]
      [%sbrk kid=plum]
  ==
```

which may be a simple cord; a wrappable paragraph; a formatted plum tree; and an indication of a nested subexpression.  Then standard `tang`, `tank`, etc. are used to produce the output, just as with other structured output.  Ultimately, these are output by `++plume`, the prettyprinter itself.

```hoon
++  plume
  |_  =plum
  +$  line  [indent=@ud text=tape]    ::  a line, indented by `indent` spaces
  +$  block  (list line)              ::  a sequence of indented lines
  ++  flat                            ::  print as a single line
  ++  tall                            ::  print as multiple lines
  ++  adjust                          ::  adjust lines to right
  ++  prepend-spaces                  ::  prepend `n` spaces to tape
  ++  window                          ::  print as list of tabbed lines
    ?@  plum  [0 (trip plum)]~        ::    trivial text
    ?-  -.plum
      %para                           ::    line-wrappable paragraph
      %sbrk                           ::    nested subexpression
      %tree                           ::    render text tree in tall mode
    ==
  ++  backstep                        ::  render using backstep indentation
  ++  rune-inline-with-block          ::
  ++  running                         ::  render tall hoon w/ running indentation
  ++  core-like                       ::  prefix by tape
  ++  linear                          ::  render onto single line
    ?@  plum                          ::    just a cord
    ?-  -.plum                        ::
      %sbrk                           ::    wide mode
      %para                           ::    wrappable text paragraph to line
      %tree                           ::    render text tree to single line
    ==
  --
```

For instance, to pretty-print a single-precision floating-point `@rs`, the [Dragon-4 algorithm](http://www.ryanjuckett.com/programming/printing-floating-point-numbers/part-2/) is used to convert to a decimal representation:

```hoon
> (@ub .3.1415926535)
0b100.0000.0100.1001.0000.1111.1101.1011
> (@ux .3.1415926535)
0x4049.0fdb
> (rlys .3.1415926535)
[%d s=%.y e=-7 a=31.415.927]
```

This is then consumed by `++plume` to produce the atom form.


##  Other Blocks

There are some other chapters of interest in `hoon.hoon`.  Take a look at the following:

- `2n: functional hacks`
- `3c: urbit time`
- `4n: virtualization` (best read after Vere and Nock sections)

![](../img/34-header-comet-3.gif){: width=100%}
