#   Ford 1

![](../img/11-header-nasa-1.png)

>Computations from inputs to outputs constitute a build graph: a directed acyclic graph where individual nodes are called actions, and arcs are called dependencies. The signals are called artifacts, and, by extension, the inputs to the action that generate one of them are also called its dependencies. (François-René Rideau (Faré), ["Build Systems"](https://ngnghm.github.io/blog/2016/04/26/chapter-9-build-systems/))

##  Learning Objectives

- Understand the high-level architecture and design intent of Ford.
- Compose and call unit tests using Ford.
- Understand top-level Ford runes:  `/-`, `/+`, `/=`, `/*`.
- Employ tanks and `~_` to produce error messages.


##  A Build System

What is a build system responsible for?  Classically, a build system serves the role of compiling, linking, and testing.  Examples include Make, GNU Autotools, Gradle, CMake, Meson, and Nix.

The proliferation of build systems should imply to you that it's the sort of thing that many feel we haven't gotten quite right yet.  For instance, [here's Eric Raymond (ESR) pining for better days ahead](http://esr.ibiblio.org/?p=8581).

What do we desire in a good build system? Faré identifies four characteristics:

1. Actions are _reproducible_: they happen without side-effects.
2. Code may be _source-addressed_: you should be able to rebuild a value by re-digesting the source code.
3. The build system is _hermetic_: no source outside of source control is necessary.
4. The build should be _deterministic_.

Urbit's build system, Ford, hews to this standard rather well.


##  The System Formerly Known as Ford

![](../img/11-header-nasa-2.png)

The build system formerly known as Ford (and now the `++ford` arm of Clay) has had one of the most productive and turbulent histories of any of the major vanes of Arvo (along with Ames and Clay).  Indeed, Ford's evolution over time is an excellent demonstration of the virtues of a cooling operating system:  Ford has become smaller, leaner, and more expressive even as it has shed complexity.

Ford is responsible for producing the Nock cores that constitute Arvo.  "Ford is capable of sequencing generic asynchronous computations. Its uses include linking source files into programs, assembling live-updating websites, and performing file-type conversions."


##  OTAs

> If your software needs to run in hell, build it that way from the start.  (Ted Blackman)

Ford is _also_ by implication responsible for one of the key properties of Urbit's evolution:  managing over-the-air updates (OTAs).

Urbit is divided into two layers:  a binary layer which provides an interface for Arvo, and the Arvo runtime.  The binary executable receives occasional updates which affect the underlying system performance, much like the JVM.  The Arvo runtime receives frequent userspace and less-frequent kernelspace updates over the network from the ship's sponsor.  Ford is responsible for receiving, processing, and implementing these live while your ship is running.

The primary properties of an OTA are that it should be:

1.  Atomic:  composed a single transaction.
2.  Self-contained:  no dependence on previous system states.
3.  Ordered:  must proceed from lowest system layer to highest.

- Reading:  [Ted Blackman `~rovnys-ricfer`, "Ford Fusion"](https://urbit.org/blog/ford-fusion/)


##  Testing Code

Among its other utilities, Ford is used for testing code, as you saw in Libraries.  Testing is designed to manifest failures so that faults and errors can be identified and corrected.  (More on this in Debugging.)

We can classify a testing regimen into various layers:

1.  Fences are barriers employed to block program execution if the state isn't adequate to the intended task.  Typically, these are implemented with `assert` or similar enforcement.  For conditions that must succeed, the failure branch in Hoon should be `!!`, which crashes the program.

2.  "Unit tests are so called because they exercise the functionality of the code by interrogating individual functions and methods. Functions and methods can often be considered the atomic units of software because they are indivisible. However, what is considered to be the smallest code unit is subjective. The body of a function can be long are short, and shorter functions are arguably more unit-like than long ones."  (Katy Huff)

    In Python and many other languages, unit tests refer to functions, often prefixed test_, that specify (and enforce) the expected behavior of a given function. Unit tests typically contain setup, assertions, and tear-down. In academic terms, they're a grading script.

    In Hoon, as you've seen, the `tests/` directory contains the relevant tests for the Ford testing framework to grab and utilize.

    Unit tests come in two categories:

    1.  Positive: the function should succeed or handle a case correctly.
    2.  Negative: the function should fail or reject a condition.

    Consider an absolute value function. The positive unit tests for absolute should accomplish a few things:

    - Verify correct behavior for positive numeric input.
    - Verify correct behavior for negative numeric input.
    - Verify correct behavior for zero input.
    - Verify that the function works for int, long (Python 2.x), float, and complex (if implemented).

    The negative unit tests for absolute should:

    - Verify an exception is raised for nonnumeric input.
    - Verify correct exceptions are raised for various kinds of input.

    Note that at this point we don't care what the function looks like, only how it behaves.

    _In extremis_, rigorous unit testing yields test-driven development (TDD).  Test-driven development refers to the practice of fully specifying desired function behavior before composing the function itself. The advantage of this approach is that it forces you to clarify ahead of time what you expect, rather than making it up on the fly.

3.  Integration tests check on how well your new or updated code integrates with the broader system.  These can be included in continuous integration (CI) frameworks like Circle or Travis-CI.  The Arvo ecosystem isn't large enough for developers outside the kernel itself to worry about this yet.

- Reading: [Tlon Corporation, "Unit Testing with Ford"](https://web.archive.org/web/20200614210451/https://urbit.org/docs/hoon/hoon-school/test-sets/)


##  Ford Runes

Way back in Generators, you encountered the ability to import a library using `/+` faslus.

Ford has its own set of particular runes, which import data and code from various locations in Clay and insert them into the subject.

- `/-` imports from `sur/` (shared structures)
- `/+` imports from `lib/` (libraries)
- `/=` imports user-specified path wrapped in a specified face
- `/*` imports file contents converted to a mark

`/+` and `/-` are the most commonly seen of these.  Prefixing the imported name with `*` imports the contents without the face; one can also rename the face:

```hoon
/+  larry, *curly, moe=stooge
```

Since tools like marks are commonly reused, it is inefficient to rebuild them every time they are accessed.  "Since building a file is a pure function, Clay memoizes the results of all builds, including builds of marks, mark conversions, and hoon source files. These memoization results are stored along with the desk and are used by later revisions of that desk."


##  Producing Error Messages

Error messages in Urbit are built of tanks.  "A `tang` is a list of `tank`s, and a `tank` is a structure for printing data. There are three types of `tank`: `leaf`, `palm`, and `rose`. A `leaf` is for printing a single noun, a `rose` is for printing rows of data, and a `palm` is for printing backstep-indented lists."

One way to include an error message in your code is the [`~_` sigcab](https://urbit.org/docs/reference/hoon-expressions/rune/sig/#sigcab) rune, described as a "user-formatted tracing printf".  What this means is that it optionally prints to the stack trace if something fails, so you can use it to contribute to the error description[:](https://upload.wikimedia.org/wikipedia/commons/a/a7/Sv-Dag_Hammarskj%C3%B6ld.ogg)  <!-- egg -->

```hoon
|=  [a=@ud]
  ~_  leaf+"This code failed"
  !!
```

When you compose your own library functions, consider include error messages for likely failure points.  We'll see more of these as we build `%ask` generators.

![](../img/11-header-nasa-3.png)
