#   Debugging Hoon

![](../img/12-header-voyager-1.png){: width=100%}

##  Learning Objectives

-   Learn principles for debugging Hoon code.
-   Enumerate the kinds of errors `mint`, `nest`, and other checks produce.
-   Grade code samples according to the standard Tlon A,B,C,D,E scheme.
-   Produce and annotate code samples to each grade above C.


##  An Ontology of Error

We distinguish different aspects of programming flaws based on their observational mode:

- A _failure_ refers to the observably incorrect behavior of a program. This can include segmentation faults, erroneous output, and erratic results.

- A _fault_ refers to a discrepancy in code that results in a failure.

- An _error_ is the mistake in human judgment or implementation that caused the fault. Note that many errors are latent or masked.

- A _latent_ error is one which will arise under conditions which have not yet been tested.

- A _masked_ error is one whose effect is concealed by another aspect of the program, either another error or an aggregating feature.

We casually refer to all of these as bugs.

An exception is a manifestation of unexpected behavior which can give rise to a failure, but some languages—notably Python—use exceptions in normal processing as well.


##  Error Sources

![](../img/12-header-voyager-2.png){: width=100%}

Let's enumerate the errors we know about at this point:

We know what Ford is:  it's the build vane.  `++ride` is the end-to-end Hoon compiler, which Ford is of course using to build the abstract syntax tree (AST).  Two `%ride failed` errors are common:  `"%ride failed to compute type"` and `"%ride failed to execute"`.  `%slim failed` means (one kind of) type issues, typically due to `%ride` failure.  `nest-fail` indicates a failure to match the expected call signature of a gate.

The `mint` errors arise from typechecking errors:

- `mint-vain` means a Hoon never executes.
- `mint-nice` occurs with casts.
- `mint-lost` means that a branch in a conditional can never be reached.

For instance, conversion without casting via auras fails because

```hoon
^-(tape ~[78 97 114 110 105 97])
```

A `fish-loop` arise when using a recursive mold definition like `list`.  Alas, this fails today:

```hoon
?=((list @) ~[1 2 3 4])
```

`generator-build-fail` most commonly results from composing code with mismatched runes (and thus the wrong children including hanging expected-but-empty slots).

`mull-grow` means it's compiling the callsite of a wet gate (a generic gate; we'll see these later)[.](https://pbs.twimg.com/media/D6qAlTAUcAA1Wub.jpg)  <!-- egg -->

If you really crash things hard—like crash the executable itself—then it's a `bail`, which has the following modes:

- `%exit`, semantic failure
- `%evil`, bad crypto
- `%intr`, interrupt
- `%fail`, execution failure
- `%foul`, assertion of failure
- `%need`, network block
- `%meme`, out of memory (this is the most common one in my experience)
- `%time`, operation timed out
- `%oops`, assertion failed (contrast with `%fail`)

Finally, although hinting at darker powers not yet unleashed, you can start a debugging console with `|start %dbug` and access it at your ship's URL followed by `~debug` (e.g., `http://localhost:8080/~debug`).

- Reading: [Tlon Corporation, "Hoon Errors"](https://urbit.org/docs/tutorials/hoon/hoon-errors/)


##  Debugging Strategies

What are some strategies for debugging?

Assuming that you are working _within_ Urbit (i.e. in or on Arvo, not in the underlying host OS), you don't have a debugger or a profiler available\*.  In that case, you have the slight help of the error message (a condition indicated as promoting "moral fiber") and some standard debugging strategies:

- Debugging stack.  Use the `!:` zapcol rune to turn on the debugging stack, `!.` zapdot to turn it off again.

- `printf` debugging.  If your code will compile and run, employ `~&` frequently to make sure that your code is doing what you think it's doing.

- The only wolf in Alaska.  Essentially a bisection search, you split your code into smaller modules and run each part until you know where the bug arose (where the wolf howled).  Then you keep fencing it in tighter and tighter until you know where it arose.

- Build it again.  Remove all of the complicated code from your program and add it in one line at a time.  For instance, replace a complicated function with either a `~&` and `!!`, or return a known static hard-coded value instead.  That way as you reintroduce lines of code or parts of expressions you can narrow down what went wrong and why.

If you run the Urbit executable with `-L`, you cut off external networking.  This is helpful if you want to mess with a _copy_ of your actual ship without producing remote effects.  That is, if other parts of Ames don't know what you're doing, then you can delete that copy (COPY!) of your pier and continue with the original.  This is an alternative to using fakezods which is occasionally helpful in debugging userspace apps in Gall.

The trouble with `%sandbox` code is that only `%home` desk code gets built by `++ford` as executable.  That may change someday, but it's why we prefer fakezods instead of development desks today[.](https://en.wikipedia.org/wiki/Category:Proposed_states_of_the_United_States)  <!-- egg -->

\*  _I have found a reference to [profiling support](https://urbit.org/docs/reference/library/5g/) in the docs.  [`~$` sigbuc](https://urbit.org/docs/reference/hoon-expressions/rune/sig/#sigbuc) also plays a role as a profiling hit counter but I've not seen it used in practice as it would be stripped out of kernel code before being released._

- Optional Reading: [OpenDSA Data Structures and Algorithms Modules Collection, "Programming Tutorials", section Common Debugging Methods](https://opendsa-server.cs.vt.edu/ODSA/Books/Everything/html/debugmethods.html)


##  Quality Hoon

Tlon suggests grading code according to certain stylistic and functional criteria:

- **F** code is incomplete code:  it looks like Hoon, at least partly.
- **D** code is compile-worthy Hoon.
- **C** code is unannotated code or code with too-strange names and formatting.
- **B** code has universal symbol definition for every name.
- **A** code has explanations for every necessary name and defines every constant where it is used.

But don't produce A code on the first pass!  Let the code mature for a while at C or B before you refine it into final form.

- Reading: [Tlon Corportion, "Hoon Style Guide"](https://urbit.org/docs/tutorials/hoon/hoon-school/style/), section "Grading"

![](../img/12-header-voyager-3.png){: width=100%}
