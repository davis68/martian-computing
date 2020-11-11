#   Arvo I

![](../img/32-header-jupiter-0.png){: width=100%}

##  Learning Objectives

-   Cover the last vanes
-   Walk through a move trace outline
*   Produce a move trace


##  Arvo

Recall the structure of Arvo:

> The Arvo kernel is compiled using the Hoon compiler as subject, the Zuse standard library is compiled using the Arvo kernel as the subject, and apps and vanes (kernel modules) are compiled using Zuse as the subject.

In a sense, the Hoon parser is the center of the subject, wrapped by Arvo, which is wrapped by the standard library Zuse.  Then the vanes are brought in:

- `%ames`, peer-to-peer networking
- `%behn`, event timing (including heartbeats)
- `%clay`, the filesystem datastore and revision-controlled build system
- `%dill`, the terminal driver
- `%eyre`, the HTTP server
- `%gall`, the userspace agent vane
- `%iris`, the HTTP client
- `%jael`, security

Recent changes included the retirement of `%hall` in favor of `chat-cli` and `%ford`'s integration into `%clay`.  Possible future changes include a proposed fusion of `%clay` and `%gall` into `%hume`.


##  The Rest of the Vanes

![](../img/32-header-jupiter-1.png){: width=100%}

We haven't talked yet about two minor vanes:  Dill and Jael.  Let's review them quickly.

### `%dill`

Dill processes keyboard events into Arvo-consumable events, and produces terminal output.

Dojo attaches to Hood as its parser.  Hood consists of Helm and Drum to manage Gall agent connections and Kiln to connect to Clay.  Dill is used incidentally throughout, and knows about Hood as a terminal agent.

(The terminal Dojo is very different from the Landscape Dojo.  See if you can locate the code for these and compare.)

For instance, `%dill` displays text according to the following process:  “The `%text` `task` prints a `tape` to the dojo by first converting it from a UTF8 tape to a list of UTF32 codepoints (`@c`'s) and then recursively popping off a character from the `tape` and sending it to to Unix to be printed into the terminal via a `%blit` event.”

Keystroke input is parsed as `%belt` `task`s containing “information about the keystroke, such as which key was pressed and from which terminal.”

- Reading: [Tlon Corporation, "Dill"](https://urbit.org/docs/tutorials/arvo/dill/)

### `%jael`

> Jael is the vane that keeps track of Azimuth related information.  For each ship, this consists of its networking keys, its revision number (or life), its breach number, and who the sponsor of the ship is.

`%jael` is intimately related to Azimuth.  Azimuth represents what we may call the exoteric view of ownership, while Jael is the esoteric view.  Jael's primary role is ship networking management and cryptography, but it also supports promises.

`%jael` segregates state into two categories:  absolute and relative.  Absolute state refers to what is known about the Azimuth PKI, ship ownership, private keys, etc.  Since not every ship is live on the network (such as a fakezod), there is also a notion of relative state, referring to what is known about the current ship only.

For instance, the `gen/code.hoon` generator is responsible for reporting the ship login code provided by Jael:

```hoon
.^(@p %j /(scot %p our)/code/(scot %da now)/(scot %p our))
```

This query basically functions as a scry into `%jael` to request the known code for the current ship.  `%jael` has to look it up from its book of secrets, however:

```hoon
%code
?.  ?=([@ ~] tyl)  [~ ~]
?.  =([%& our] why)
  [~ ~]
=/  who  (slaw %p i.tyl)
?~  who  [~ ~]
=/  sec  (~(got by jaw.own.pki.lex) lyf.own.pki.lex)
=/  cub  (nol:nu:crub:crypto sec)
``[%noun !>((end 6 1 (shaf %pass (shax sec:ex:cub))))]
```

Ultimately, this depends on `lex` which is the durable state of Jael.

```hoon
=|  lex/state
$:  our=ship        ::  our: identity
    now=@da         ::  now: current time
    eny=@uvJ        ::  eny: unique entropy
    ski=sley        ::  ski: namespace resolver
==
```

Jael is responsible for making sure that a booted ship actually owns the private keys corresponding to the public ownership keys.  To this end, it is instructive to compare the bootstrapping process of a real ship to that of a fakezod.

Real ship:

```hoon
%dawn  :: real ship booting
::  single-homed
~|  [our who.seed.tac]
?>  =(our who.seed.tac)
::  save our boot block
=.  boq.own.pki  bloq.tac
::  save our ethereum gateway (required for galaxies)
=.  nod.own.pki
  %+  fall  node.tac
  (need (de-purl:html 'http://eth-mainnet.urbit.org:8545'))
::  save our parent signature (only for moons)
=.  sig.own.pki  sig.seed.tac
::  load our initial public key
=/  spon-ship=(unit ship)
  =/  flopped-spon  (flop spon.tac)
  ?~(flopped-spon ~ `ship.i.flopped-spon)
=.  pos.zim.pki
  =/  cub  (nol:nu:crub:crypto key.seed.tac)
  %+  ~(put by pos.zim.pki)
    our
  [0 lyf.seed.tac (my [lyf.seed.tac [1 pub:ex:cub]] ~) spon-ship]
::  our initial private key
=.  lyf.own.pki  lyf.seed.tac
=.  jaw.own.pki  (my [lyf.seed.tac key.seed.tac] ~)
::  set initial domains
=.  tuf.own.pki  turf.tac
::  our initial galaxy table as a +map from +life to +public
=/  spon-points=(list [ship point])
  %+  turn  spon.tac
  |=  [=ship az-point=point:azimuth]
  ~|  [%sponsor-point az-point]
  ?>  ?=(^ net.az-point)
  :*  ship
      continuity-number.u.net.az-point
      life.u.net.az-point
      (malt [life.u.net.az-point 1 pass.u.net.az-point] ~)
      ?.  has.sponsor.u.net.az-point  ~
      `who.sponsor.u.net.az-point
  ==
=/  points=(map =ship =point)
  %-  ~(run by czar.tac)
  |=  [=a=rift =a=life =a=pass]
  ^-  point
  [a-rift a-life (malt [a-life 1 a-pass] ~) ~]
=.  points
  (~(gas by points) spon-points)
=.  +>.$
  %-  curd  =<  abet
  (public-keys:~(feel su hen our now pki etn) %full points)
::  start subscriptions
=.  +>.$  (poke-watch hen %azimuth-tracker nod.own.pki)
=.  +>.$
  ?:  &
    %-  curd  =<  abet
    (sources:~(feel su hen our now pki etn) ~ [%| %azimuth-tracker])
  ?-    (clan:title our)
      %czar
    %-  curd  =<  abet
    (sources:~(feel su hen our now pki etn) ~ [%| %azimuth-tracker])
      *
    =.  +>.$
      %-  curd  =<  abet
      %+  sources:~(feel su hen our now pki etn)
        (silt (turn spon-points head))
      [%| %azimuth-tracker]
    %-  curd  =<  abet
    (sources:~(feel su hen our now pki etn) ~ [%& (need spon-ship)])
  ==
::  initialize other vanes in (necessary) order
=.  moz
  %+  weld  moz
  ^-  (list move)
  :~  [hen %give %init our]
      [hen %slip %e %init our]
      [hen %slip %d %init our]
      [hen %slip %g %init our]
      [hen %slip %c %init our]
      [hen %slip %a %init our]
  ==
+>.$
```

(Note the call to the Ethereum Remote Procedure Call endpoint at `http://eth-mainnet.urbit.org:8545`.)

Fakezod:

```hoon
%fake  :: fake ship booting
::  single-homed
?>  =(our ship.tac)
::  fake keys are deterministically derived from the ship
=/  cub  (pit:nu:crub:crypto 512 our)
::  our initial public key
=.  pos.zim.pki
  %+  ~(put by pos.zim.pki)
    our
  [rift=1 life=1 (my [`@ud`1 [`life`1 pub:ex:cub]] ~) `(^sein:title our)]
::  our private key; private key updates are disallowed for fake ships
=.  lyf.own.pki  1
=.  jaw.own.pki  (my [1 sec:ex:cub] ~)
::  set the fake bit
=.  fak.own.pki  &
::  initialize other vanes per the usual procedure except for %jael
=.  moz
  %+  weld  moz
  ^-  (list move)
  :~  [hen %give %init our]
      [hen %slip %e %init our]
      [hen %slip %d %init our]
      [hen %slip %g %init our]
      [hen %slip %c %init our]
      [hen %slip %a %init our]
  ==
+>.$
```

- Optional Reading: [Curtis Yarvin `~sorreg-namtyv` & Galen Wolfe-Pauly `~ravmel-ropdyl`, "2016-10-6 Update"](https://urbit.org/updates/2016-10-6-update/), section "`%jael`: reference code, PKI, and personal ledger"


##  Key Internal Structures

![](../img/32-header-jupiter-2.png){: width=100%}

Let's start looking into `sys/arvo.hoon`.  We will only introduce and comment on the major data structures and molds to expect; we'll cut a lot of the minor ones.  Keep in mind that most of these are not used in `arvo.hoon` itself, but are set up so that all vanes know about them.

```hoon
|%
+|  %global
::  $arch: fundamental node
+$  arch  [fil=(unit @uvI) dir=(map @ta ~)]
::  $beak: global context
+$  beak  (trel ship desk case)
::  $beam: global name
+$  beam  [beak s=path]
::  $bone: opaque duct handle
+$  bone  @ud
::  $case: global version
+$  case
  $%  [%da p=@da]       :: date
      [%tas p=@tas]     :: label
      [%ud p=@ud]       :: sequence
  ==
::  $cage: marked vase
+$  cage  (cask vase)
::  +cask: marked data builder
++  cask  |$  [a]  (pair mark a)
::  $desk: local workspace
+$  desk  @tas
::  $dock: message target
+$  dock  (pair @p term)
::  $mark: symbolic content type
+$  mark  @tas
::  $ship: network identity
+$  ship  @p
::  $sink: subscription
+$  sink  (trel bone ship path)
::
+|  %meta
::  +hypo: type-associated builder
++  hypo  |$  [a]  (pair type a)
::  $meta: meta-vase
+$  meta  (pair)
::  $maze: vase, or meta-vase
+$  maze  (each vase meta)
::
+|  %interface
::  $ball: dynamic kernel action
+$  ball  (wite [vane=term task=maze] maze)
::  $curd: tagged, untyped event
+$  curd  (cask)
::  $duct: causal history
+$  duct  (list wire)
::  +hobo: %soft task builder
++  hobo
::  $goof: crash label and trace XX fail/ruin/crud/flaw/lack/miss
+$  goof  [mote=term =tang]
::  $mass: memory usage
+$  mass
::  $monk: general identity
+$  monk  (each ship (pair @tas @ta))
::  $move: cause and action
+$  move  [=duct =ball]
::  $ovum: card with cause
+$  ovum  (pair wire curd)
::  $scry-sample: vane +scry argument
+$  scry-sample
::  $vane-sample: vane wrapper-gate aargument
+$  vane-sample  [our=ship now=@da eny=@uvJ ski=slyd]
::  $sley: namespace function
+$  sley
::  +wind: kernel action builder
++  wind
::  $wire: event pretext
+$  wire  path
::  +wite: kernel action/error builder
++  wite  |$  [note gift]
::
+|  %implementation
::  $pane: kernel modules
+$  pane  (list (pair @tas vase))
::  $pone: kernel modules old
+$  pone  (list (pair @tas vise))
::  $vane: kernel module
+$  vane  [=vase =worm]
::  $vile: reflexive constants
+$  vile
--
```

`++wite` divides kernel actions into five fields of action:

- `%hurl`, an error
- `%pass`, to pass a note forward along a given wire:  “a `%pass` says to push this wire onto the duct and transfer control to the receiving vane”
- `%slip`, to transfer control to the receiving vane without altering the `duct` (a gift in response to a slip will go to the caller of the vane that sent the slip rather than the vane that actually sent the slip)
- `%give`, to return a gift backwards
- `%unix`, to call out to the system via the runtime binary

The heart of `%arvo` itself, the event handler, is rather charmingly simple:

```hoon
::  arvo: structural interface core
++  arvo
  |%
  ++  come  |=  [@ @ @ pram vise pone]
            (come:soul +<)
  ++  load  |=  [@ @ @ pram vase pane]
            (load:soul +<)
  ++  peek  |=  *
            =/  rob  (^peek ;;([@da path] +<))
            ?~  rob  ~
            ?~  u.rob  ~
            [~ u.u.rob]
  ++  poke  |=  *
            =>  .(+< ;;([now=@da ovo=ovum] +<))
            (poke:soul now ovo)
  ++  wish  |=(* (^wish ;;(@ta +<)))
  --
```

It is simply a pure function call handler.  We'll come back to this in Arvo II.

(`++soul` artfully refers to `.`, the current subject.)

![](../img/32-header-jupiter-3.png){: width=100%}
