#   Command-Line Interface

![](../img/31-header-phobos-0.png){: width=100%}

##  Learning Objectives

- Diagram how `%dill` instruments terminal events.
- Produce a command-line interface app using `sole` and `shoe`.

Urbit traffics only in events.  Every occurrence or action in any part of the system must become an event to be legible to Arvo.  A command-line interface is conventionally a text user interface (TUI) (although not all TUIs are CLIs and vice versa).

A command line like Dojo is useful for instrumenting and interacting with agents interactively.  A long-running agent or a graphical interface (like Landscape) is preferred for more complex or alternatively more asynchronous interactions.

`%dojo` is the main interface for the command-line user; since all events are well-formed Hoonish, if you know an agent's interface you can always accomplish anything on a ship in Dojo that you can do through Landscape.  (The trick, of course, is knowing the arcana, which at this point in history frequently requires recourse to [GitHub issues](https://github.com/urbit/urbit/issues).)

Even in Dojo, however, you can change your CLI.  By pressing `Ctrl`+`X`, you can cycle through CLI interfaces:  at least `%chat-cli` and `%dojo` are running on your ship now.  There is also `%shoe`, which is an illustrative example of a Gall agent CLI.

- Optional Reading: [Tlon Corporation, `chat-cli.hoon`](https://github.com/urbit/urbit/blob/master/pkg/arvo/app/chat-cli.hoon)


##  Building a CLI Agent

![](../img/31-header-phobos-1.png){: width=100%}

### `sole` Library

We previously examined `sole`, which provided some structures useful in `%say` and `%ask` generators.  Let's recap on `%sole`.

`sole` mold builders are designed to produce structured results or events.  Their purpose is to provide a standard way of interfacing agent and generator components, both to other agents/generators and to Arvo.

```hoon
|%
++  sole-action                                 ::  sole to app
++  sole-buffer                                 ::  command state
++  sole-change                                 ::  network change
++  sole-clock                                  ::  vector clock
++  sole-edit                                   ::  shared state change
++  sole-effect                                 ::  app to sole
  $%  {$bel ~}                                  ::  beep
      {$blk p/@ud q/@c}                         ::  blink+match char at
      {$clr ~}                                  ::  clear screen
      {$det sole-change}                        ::  edit command
      {$err p/@ud}                              ::  error point
      {$klr p/styx}                             ::  styled text line
      {$mor p/(list sole-effect)}               ::  multiple effects
      {$nex ~}                                  ::  save clear command
      {$pro sole-prompt}                        ::  set prompt
      {$sag p/path q/*}                         ::  save to jamfile
      {$sav p/path q/@}                         ::  save to file
      {$tab p/(list {=cord =tank})}             ::  tab-complete list
      {$tan p/(list tank)}                      ::  classic tank
      {$txt p/tape}                             ::  text line
      {$url p/@t}                               ::  activate url
  ==                                            ::
++  sole-command                                ::  command state
++  sole-prompt                                 ::  prompt definition
++  sole-share                                  ::  symmetric state
++  sole-dialog                                 ::  standard dialog
++  sole-input                                  ::  prompt input
++  sole-result                                 ::  conditional result
++  sole-product                                ::  success result
++  sole-args                                   ::  generator arguments
```

In the past, we've only used `++sole-result` explicitly, although [`lib/generators.hoon`](https://github.com/urbit/urbit/blob/master/pkg/arvo/lib/generators.hoon) used other pieces such as `++sole-prompt` and `++sole-input` internally.

We still don't need most of these to start a CLI agent, but you can see the breadth of options available to you.

- Reading: [Tlon Corporation, `sur/sole.hoon`](https://github.com/urbit/urbit/blob/master/pkg/arvo/sur/sole.hoon)
- Optional Reading: [Tlon Corporation, `lib/sole.hoon`](https://github.com/urbit/urbit/blob/master/pkg/arvo/lib/sole.hoon)

### `shoe` Library

[`lib/shoe.hoon`](https://github.com/urbit/urbit/blob/master/pkg/arvo/lib/shoe.hoon) provides everything _besides_ text rendering for CLI apps.

`shoe` produces either Gall cards or formatted `shoe-effect` cards that are intended for direct passing to all connected `shoe` apps.  The `shoe-effect` cards can, for instance, pass `sole-effect`s (`%bel`, `%pro`, `%txt`, etc.).

```hoon
|%
::  $card: standard gall cards plus shoe effects
+$  card
::  $shoe-effect: easier sole-effects
+$  shoe-effect
  $%  ::  %sole: raw sole-effect
      [%sole effect=sole-effect]
      ::  %table: sortable, filterable data, with suggested column char widths
      [%table head=(list dime) wide=(list @ud) rows=(list (list dime))]
      ::  %row: line sections with suggested char widths
      [%row wide=(list @ud) cols=(list dime)]
  ==
::  +shoe: gall agent core with extra arms
++  shoe
::  +default: bare-minimum implementations of shoe arms
++  default
  |_  =bowl:gall
  ++  command-parser        :: input parser, per-session
  ++  tab-list              :: tab autocompletion options
  ++  on-command            :: called on valid command
  ++  can-connect           :: determines if session can connect
  ++  on-connect            :: initialization on session connection
  ++  on-disconnect         :: shutdown when session disconnects
  --
::  +agent: creates wrapper core that handles sole events and calls shoe arms
++  agent
++  draw
  |%
  ++  row
  ++  col-as-lines
  ++  col-as-text
  ++  alignment
  ++  break-sets
  ++  break
  ++  pad
  --
--
```

`++command-parser` is where a lot of the magic takes place; it relies thoroughly on your ability to parse text.  (We saw this some in Text Processing; we'll see more in Hoon I.)  It can be a fairly sophisticated arm, as the `++parser` arm in `app/chat-cli.hoon`.

A simple command parser could look like this:

```hoon
++  command-parser
  |=  sole-id=@ta
  ^+  |~(nail *(like [? command]))
  %+  stag  &
  (perk %demo %row %table ~)
```

`nail`, `++like`, `stag`, and `++perk` are all parsing rule concepts. Parsing rules are complex but can be reviewed in the [text parsing tutorial](https://urbit.org/docs/tutorials/hoon/parsing/).

Once you have a working app, you can use `|link` to connect to it at the console.  Switch to it using `Ctrl`+`X`.  (`|unlink` does the opposite.)

What could you make with a command-line app?  Some ideas:

- Games like Yahtzee or poker or 42 (for which you already have some library code ready)
- Automation language like a simple variant of `sh` or PowerShell
- Command-line editor like Nano or Vim or [`ed`](https://github.com/crides/ed.hoon)
- Dungeon game like Zork or a roguelike

The sky's the limit!

- Reading: [Tlon Corporation, "CLI apps"](https://urbit.org/docs/tutorials/hoon/cli-tutorial/)
- Optional Reading: [Tlon Corporation, `lib/shoe.hoon`](https://github.com/urbit/urbit/blob/master/pkg/arvo/lib/shoe.hoon)
- Optional Reading: [`~hosbud-socbur`, `ed`](https://github.com/crides/ed.hoon)


##  Unicode

![](../img/31-header-phobos-2.png){: width=100%}

The `@c` aura denotes an arbitrary-length UTF-32 value.  This is used extensively in the console subsystems like `%dill` and `drum`, but is frequently not used elsewhere (`@t` suffices).  Most Unicode handling in Urbit is just passing data around rather than processing it, so compatibility is fairly straightforward.  (Codepoints less than 32, however, are manually excluded for some reason, except for `\n` newline 0x0A.)

[`++tuba`](https://urbit.org/docs/reference/library/4b/#tuba) and [`++tufa`](https://urbit.org/docs/reference/library/4b/#tufa) convert a `(list @t)` (`tape`) to `(list @c)` and back again.  We call a list of individual codepoints `(list @c)` a `tour`.
