#   Entering the Dojo

![](../img/01-header-goddard.png)

##  Learning Objectives

-   Operate dojo by entering Hoon commands.
-   Mount the Unix filesystem and commit changes as necessary.
-   Use built-in or provided tools (gates and generators).
-   Identify elements of Hoon such as runes, atoms, and cells.

_You will need access to a Unix or Linux system to work with Urbit right now.  macOS will do, being derived from BDS Unix via NeXTSTEP.  Windows Subsystem for Linux is provisionally supported.  You will probably get the most value out of this lesson by reading this page once, completing the questions and associated setup, then reviewing this page._

_This lesson requires you to have a running Urbit instance, preferably a "fakezod."  I recommend you scan this page, then complete the first exercise to get a running fakezod.  Then return and thoroughly complete this page's material._


##  Stepping Into the Dojo

To run Urbit, you need the OS and an ID.  In the current state of affairs, software development runs the risk of unvetted or buggy code without the possibility of recontainment.  On your main ship, it can lead to drastic problems.  Thus you will start working with Urbit in this lesson by creating a _fakezod_, or a "dummy ship" unconnected to the network but suitable for development.  (Instructions for a creating a fakezod are included on the next page.)

At this point, there are three ways to work with Urbit:  Dojo, Landscape, and via an API.

1.  Dojo is the command-line interface you see by default.
2.  An HTTP API is supported.
3.  API connections are in third-party development and supported for some languages, including [Python](https://pypi.org/project/urlock/).
4.  Landscape is accessible at `localhost` in your browser if port 80 is available, or at another random port if not.  (Check the boot log for the chosen port, commonly 8080 or 8888.)


##  Interfacing with Unix

Urbit uses the Clay vane as its "filesystem"—really a version-controlled data store.  We can synchronize Clay with our Unix filesystem to edit files in using our favorite editor and share files with other users.

To initialize your filesystem synchronization, run `|mount %` once.  This creates a `home/` directory with a number of standard child directories.

To synchronize your Unix-side changes to Clay, run `|commit %home`.

![](../img/01-header-goddard-1.png)


##  Using Built-In Tools

There are, of course, many helpful tools built right into Dojo.

For instance, `trouble` is a troubleshooting tool frequently used when analyzing system problems.  Invoke it as `+trouble`.

A simple "Hello, world" tool is available as `+deco`.

To see the contents of a file, use `+cat`:  `+cat %/gen/deco/hoon`.

To view the current filesystem on Clay, use `+ls`:  `+ls %`.

In general, `+` precedes generators, or standalone functions, while `|` precedes system service calls.

`|mass` shows the current memory usage on the loom.  (The loom is like heap + stack memory; we'll explore it later.)

`|sync` checks for automatic synchronization (_over-the-air_ updates) for your ship.

`|ota` configures where OTA updates to your ship come from (since Urbit is peer-to-peer).

`|moon` generates a daughter point, a moon, at a random 64-bit address.

You've seen `|mount` and `|commit` already, which coordinate the "external" file system (Unix) with the "internal" file system (Clay data store).


##  Reading Your First Hoon

As mentioned, Hoon:Urbit::C:Unix.  Similar to how C compiles to assembler for execution, Hoon is a macro language on top of a simple Turing-complete language called Nock.

Urbit is a "subject-oriented" system.  Right now, what that means to you is that rather than an environment stack, Urbit has a nested tree of values:  _everything_ in Urbit is a binary tree.  The [docs](https://urbit.org/docs/hoon/hoon-school/the-subject-and-its-legs/) explain this thus:  "every Hoon expression is evaluated relative to some subject, [and] roughly, the subject defines the environment in which a Hoon expression is evaluated."

For a userspace program, the subject is Zuse, the standard library (which wraps around Arvo and Hoon).  Dojo provides a slightly broader subject with some convenience features built in to ease programming.  Any Hoon expression (or hoon) evaluates to a tree, wherein each operation is a macro reducing ultimately to Nock.  Hoon is written using "runes," a lapidary composition technique which emphasizes program structure.

Try each of the following single-line Hoon expressions in the Dojo.  Notice that in many cases the Dojo will not let you type certain characters—Dojo parses your input in real time to enforce well-formed Hoon.

    (add 1 1)
    (add 1.000 1)
    (sub 1.000 1)
    =(5 5)
    =(10 0)
    ?:  =(5 5)  "equal"  "unequal"
    ::  This is a comment.

Play with these expressions and figure out what you can successfully change and what not.  Dojo parses input in real time and generally does a good job with preventing poorly-formed input.  You may see your input never appear or immediately disappear if it is not well-formed.

Runes generally have a fixed number of children:  for instance, a function call using `%-` actually takes two children, a function name and a list of arguments.  (We don't call these "functions," by the way, that's a concession until you're used to the terminology.)  Because runes have a fixed number of children, the Lispy proliferation of parens is contained.

The notation for function calls is Lisp-like.  (This is actually an irregular form, available for convenience.  It reduces in parsing to an equivalent formal structure.)

Let's use the Dojo to define a simple gate.  Copy and paste the following into your Dojo.

```hoon
=add-3 |=  n=@ud
(add n 3)
```

This short program contains one rune (`|=`) and a function call (irregular form for `%-`):

- `=` with a name is a Dojo shortcut for defining a value ("pinning a face to the [Dojo] subject"); it takes a name and a value, the value here being the entire gate
- `|=` produces a "gate," thought of as a function entry point; it has two children, a list of arguments and a value, the value here being the following line
- `@ud` is not a rune, but a type specifier (unsigned decimal integer)
- `(add n 3)` is shorthand for a function call, which gives you Lisp-like access to the `%-` rune.

Longer programs are frequently written and stored as _generators_, in the `home/gen/` folder as `.hoon` files.  The most basic form of generator is Hoon that produces a "gate" definition, as below.  Once you have a fakezod (next page), save the following text to a file `home/gen/mod3.hoon`, synchronize it to Urbit using `|commit %home`, and run it with `+mod3 100`.

This example is a fair bit more complicated; revisit it once you're more comfortable with Hoon.

```hoon
!:
::  List all natural numbers below 100 that are multiples of 3.
|=  end=@ud
=/  index=@ud  1
=/  values=(list @ud)  ~
::  Start "loop" (self-replacing tree structure) to build list.
|-  ^-  (list @ud)
?:  =(end index)
  values
::  Check for modulus of index by 3 to be 0.
?:  =(0 (mod index 3))
  ~& index
  $(index (add 1 index), values (weld values ~[index]))
$(index (add 1 index))
```

Each two-character entry is a rune, analogous to a keyword in other languages.  From top to bottom, we see the following runes:

- `!:` turns on the debugging context; it's frequently used when developing code
- `::` precedes a comment
- `|=` produces a "gate," thought of as a function entry point
- `@ud` is not a rune, but a type specifier (unsigned decimal integer)
- `=/` defines a variable of a given type
- `|-` starts a "trap," thought of here as a loop recursion point
- `^-` constrains the expected type, here a list of `@ud`
- `?:` tests a boolean condition
- `=()` is not a rune, but a shorthand test for equality
- `~` is not a rune, but nil (the end of a list)
- `~&` outputs a value to the screen, basically a `printf`
- `%-` is a function call, implied by the `add` and `weld`
- `$()` is not a rune, but constructs a new subject `$` by re-executing the code of the current subject `$`.  `$` is implicitly defined.  (This is a subtle point we will revisit:  I introduce it now because it will take you a while to wrap your head around it.)

This gate accepts a single input argument `end` of type unsigned decimal integer.  An index variable is initialized before the looping structure.  The loop will return a value of type list of unsigned decimal integers.  `end` is compared to `index`, and if it is equal to `index`, the entire list `values` is returned.  During normal operation, though, it will not be equal yet, so the next check, of whether `index` modulo 3 is zero (i.e., the number is divisible by three).  If it is, then the number is printed to the screen and the subject is replaced by an identical subject except for two changes:  `index` is increased by one, and `values` is replaced by a new list fused from the old `values` and `index`.  If it is not, only the `index` is changed.

Hoon takes some getting used to.  The upside is that similar kinds of operations are expressed using similar runes; the downside is that learning to read the runes takes time.

![](../img/01-header-goddard-2.png)


##  Setting Up a Real Urbit ID

Your Urbit ID is cryptographic ownership of a single piece of Urbit address space (more on that in _Azimuth 1_).  Most IDs are what are called "planets," or 32-bit identities[.](https://en.wikipedia.org/wiki/Sylacauga_%28meteorite%29)  <!-- egg -->

In the exercises, you will access a planet and its keyfile and create a permanent online pier for accessing the planet.
