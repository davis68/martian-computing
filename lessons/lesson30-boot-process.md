#   The Boot Process

![](../img/30-header-titan-0.png){: width=100%}

##  Learning Objectives

-   Outline the Urbit bootstrapping process for a new pier.


##  A New Ship

![](../img/30-header-titan-1.png){: width=100%}

Whenever you start a new ship for the first time, there is a complex and rather slow process to get Arvo running.

In this lesson, we are going to talk about how Arvo actually gets running on the Urbit VM layer.

##  Some Words

![](../img/30-header-titan-2.png){: width=100%}

The following discussion relies on a few definitions we haven't seen before:

- `king`:  the Arvo system running atop the binary
- [`pill`](https://urbit.org/docs/glossary/pill/):  a specific bootstrap sequence, a log of events to create Arvo and vanes; “a serialized, declarative set of steps to initialize Arvo”
- `serf`:  the binary daemon (including jets)

Three kinds of pills matter:

- `brass`:  complete bootstrap sequence
- `ivory`:  initial boot sequence of minimal kernel without vanes (also used for runtime support); can evaluate against `%zuse` withoutreimplementing everything in the host environment
- `solid`:  a partial `brass` pill (developer tool); doesn't recompile vanes

Pills—`solid` pills—are a critical part of the kernel development process.  We'll see them again in Vere.


##  Boot Log

### Lifecycle Formula

![](../img/30-header-titan-3.png){: width=100%}

The first part of a typical boot log looks like the following:

```hoon
$ urbit -c comet
~
urbit 0.10.8
boot: home is /home/davis68/urbit/dev/comet
loom: mapped 2048MB
lite: arvo formula 50147a8a
lite: core 590c9d56
lite: final state 590c9d56
boot: downloading pill https://bootstrap.urbit.org/urbit-v0.10.8.pill
boot: mining a comet. May take up to an hour.
If you want to boot faster, get an Urbit identity.
boot: found comet ~latwel-filder-donrep-padres--lanmyr-napsup-ritlyx-marzod
boot: retrieving latest block
boot: verifying keys
boot: getting sponsor
boot: retrieving galaxy table
boot: retrieving network domains
boot: retrieving keys for sponsor ~marzod
boot: retrieving keys for sponsor ~zod
loom: mapped 2048MB
boot: protected loom
live: logical boot
boot: installed 268 jets
```

We will step through each line with commentary.

```hoon
~
urbit 0.10.8
```

Welcome to Urbit.  You're running a particular binary version, which includes the jets and other VM specs.  We call this the serf or the daemon.

```hoon
boot: home is /home/username/urbit/comet
```

Your pier lives here.

```hoon
loom: mapped 2048MB
```

The loom is the central 2GB memory which Arvo can address locally.  (This is currently a system design constraint.)

```hoon
lite: arvo formula 50147a8a
lite: core 590c9d56
lite: final state 590c9d56
```

The daemon has access to an `ivory` pill.  An `ivory` pill is a pristine release, the events necessary to create the current version of the Arvo kernel and anything atop it (like `%clay`).  This reports the state/version/hash of that pill.

```hoon
boot: downloading pill https://bootstrap.urbit.org/urbit-v0.10.8.pill
```

However, after the `ivory` bootstrap the system immediately needs the up-to-date `brass` pill, which it acquires if you haven't already downloaded it and specified it as a command-line flag option.

> A brass pill is a recipe for a complete bootstrap sequence, starting with a bootstrap Hoon compiler as a Nock formula.  It compiles a Hoon compiler from source, then uses it to compile everything else in the kernel.  (`~master-morzod`)

```hoon
boot: mining a comet. May take up to an hour.
If you want to boot faster, get an Urbit identity.
boot: found comet ~latwel-filder-donrep-padres--lanmyr-napsup-ritlyx-marzod
```

The statement "mining a comet" can be misleading, as what's happening is negotiation with `~marzod` to sponsor said comet.  `~marzod` is the only star currently configured to take in keyless comets.  The list is specified publicly at `https://bootstrap.urbit.org/comet-stars.jam`.

```hoon
boot: retrieving latest block
boot: verifying keys
boot: getting sponsor
boot: retrieving galaxy table
boot: retrieving network domains
boot: retrieving keys for sponsor ~marzod
boot: retrieving keys for sponsor ~zod
```

The latest block is the current state of the Azimuth PKI as brokered on the Ethereum blockchain.  Keys are necessary to communicate securely with peers.

The galaxies maintain a DNS lookup table for locating ships on the network.  Your new ship has to retrieve all of these so that it knows where to send things.  It also has to know

```hoon
loom: mapped 2048MB
boot: protected loom
live: logical boot
```

The loom has been configured; `logical boot` is invoked for an empty image.

```hoon
boot: installed 268 jets
```

Jets are fast implementations of Hoon/Nock code.  The number of installed jets can vary based on your binary and your system.

If you are interested in delving into the Vere code for the above, you can look in [`pkg/urbit/vere/king.c`](https://github.com/urbit/urbit/blob/master/pkg/urbit/vere/king.c) and [`pkg/urbit/vere/dawn.c`](https://github.com/urbit/urbit/blob/master/pkg/urbit/vere/dawn.c) for details.

### The Main Sequence

![](../img/30-header-titan-3.png){: width=100%}

The next part of a new boot log consists of setting up Arvo for the first time.  Everything up to this point has been a preface for what is known as the _main sequence_:

```hoon
---------------- playback starting ----------------
pier: replaying events 1-18
1-b
1-c (compiling compiler, wait a few minutes)
ride: parsing
ride: compiling
ride: compiled
1-d
1-e
ride: parsing
ride: compiling
ride: compiled
1-f
ride: parsing
ride: compiling
ride: compiled
1-g
arvo: assembly
arvo: assembled
arvo: formal event
arvo: formal event
arvo: formal event
zuse: ~disfed-fotnes
arvo: metamorphosis
arvo: metamorphosed
arvo: formal event
vane: %a ~maglet-masfet
vane: parsed ~dabrel-hannep
vane: compiled ~simfus-pagmul
arvo: formal event
vane: %b ~nocsed-radtul
vane: parsed ~nissug-ronput
vane: compiled ~micner-filres
arvo: formal event
vane: %c ~liblep-nosnyd
vane: parsed ~pitryl-bitset
vane: compiled ~boldus-nocsen
arvo: formal event
vane: %d ~havser-tagmug
vane: parsed ~riblec-rapsec
vane: compiled ~natwer-lasdeg
arvo: formal event
vane: %e ~sitwyd-divrel
vane: parsed ~borleb-ravryt
vane: compiled ~torhep-ritsup
arvo: formal event
vane: %g ~tiddyn-rovfed
vane: parsed ~figryp-diswer
vane: compiled ~ragput-minfer
arvo: formal event
vane: %i ~rivdyn-fosfer
vane: parsed ~pitreg-podbyt
vane: compiled ~sigres-missum
arvo: formal event
vane: %j ~wanret-figfun
vane: parsed ~socnys-nibwed
vane: compiled ~botsyt-sidbyr
arvo: formal event
gall: direct morphogenesis
gall: not running %azimuth-tracker yet, got %poke
gall: not running %azimuth-tracker yet, got %watch
arvo: formal event
gall: loading %hood
gall: not running %chat-cli yet, got %watch
gall: not running %dojo yet, got %watch
gall: loading %chat-store
gall: loading %contact-store
gall: loading %group-store
gall: loading %invite-store
gall: loading %link-store
gall: loading %metadata-store
gall: loading %permission-store
gall: loading %chat-hook
gall: loading %file-server
gall: loading %acme
gall: loading %azimuth-tracker
gall: not running %eth-watcher yet, got %watch
gall: not running %eth-watcher yet, got %poke
gall: not running %eth-watcher yet, got %poke
gall: loading %chat-cli
gall: loading %chat-view
gall: loading %clock
gall: loading %contact-hook
gall: loading %contact-view
gall: loading %dojo
gall: loading %eth-watcher
gall: loading %glob
gall: loading %goad
gall: loading %graph-pull-hook
gall: loading %graph-push-hook
gall: not running %graph-store yet, got %watch
gall: loading %graph-store
gall: loading %group-pull-hook
gall: loading %group-push-hook
gall: loading %invite-hook
gall: loading %launch
gall: loading %lens
gall: loading %link-listen-hook
gall: loading %link-proxy-hook
gall: loading %link-view
gall: loading %metadata-hook
gall: loading %permission-group-hook
gall: loading %permission-hook
gall: loading %ping
gall: loading %publish
gall: loading %s3-store
gall: loading %soto
gall: loading %spider
gall: loading %weather
pier: (18): play: done
---------------- playback complete ----------------
```

The main sequence is concerned with getting the entire system in good nick before Arvo runs.

```hoon
pier: replaying events 1-18
```

Arvo is going to play the pill's events to configure itself.

```hoon
1-b
1-c (compiling compiler, wait a few minutes)
ride: parsing
ride: compiling
ride: compiled
1-d
1-e
ride: parsing
ride: compiling
ride: compiled
1-f
ride: parsing
ride: compiling
ride: compiled
1-g
arvo: assembly
arvo: assembled
```

Steps `1-b` through `1-g` are setting up the

- `1-b`:  activate the compiler gate
- `1-c`:  compile the compiler source
- `1-d`:  recompile the compiler (enabling reflection)
- `1-e`:  get the type of the kernel core
- `1-f`:  compile Arvo source against the kernel core
- `1-g`:  create the Arvo kernel with subject of the kernel core

After this, Arvo has been assembled.  The lifecycle evaluation of the bootstrap sequence has been completed now.

```hoon
arvo: formal event
zuse: ~disfed-fotnes
```

Next, Zuse has to wrap Arvo to provide the standard library for the vanes.

```hoon
arvo: metamorphosis
arvo: metamorphosed
```

Arvo now sheds its larval form.  This means that it has acquired a single home in the kernel and has identity, entropy, and the standard library.

```hoon
vane: %a ~maglet-masfet
vane: parsed ~dabrel-hannep
vane: compiled ~simfus-pagmul
arvo: formal event
vane: %b ~nocsed-radtul
vane: parsed ~nissug-ronput
vane: compiled ~micner-filres
arvo: formal event
vane: %c ~liblep-nosnyd
vane: parsed ~pitryl-bitset
vane: compiled ~boldus-nocsen
arvo: formal event
vane: %d ~havser-tagmug
vane: parsed ~riblec-rapsec
vane: compiled ~natwer-lasdeg
arvo: formal event
vane: %e ~sitwyd-divrel
vane: parsed ~borleb-ravryt
vane: compiled ~torhep-ritsup
arvo: formal event
vane: %g ~tiddyn-rovfed
vane: parsed ~figryp-diswer
vane: compiled ~ragput-minfer
arvo: formal event
vane: %i ~rivdyn-fosfer
vane: parsed ~pitreg-podbyt
vane: compiled ~sigres-missum
arvo: formal event
vane: %j ~wanret-figfun
vane: parsed ~socnys-nibwed
vane: compiled ~botsyt-sidbyr
arvo: formal event
```

Each Arvo vane (`%ames`, `%behn`, `%clay`, `%dill`, `%eyre`, `%gall`, `%iris`, and `%jael`) is compiled.  The `@q` annotations are event identifiers; it's unclear to me why they are output.

At this point, the kernel and userspace have been built.

### Startup

![](../img/30-header-titan-4.png){: width=100%}

```hoon
ames: live on 55038
http: web interface live on http://localhost:8081
http: loopback live on http://localhost:12322
pier (25): live
ames: larva: drain
ames: metamorphosis
ames: czar zod.urbit.org: ip .35.247.119.159
; ~zod is your neighbor
; ~marzod is your neighbor
~latwel_marzod:dojo>
```

We're close to having a running Arvo.  Now we just need to turn everything on:

```hoon
ames: live on 55038
http: web interface live on http://localhost:8081
http: loopback live on http://localhost:12322
```

Ames gets started on an internal port.  The standard interface gets started at a random port in the `8000` range, if unspecified, and the [loopback](https://en.wikipedia.org/wiki/Loopback) gets started as well.

```hoon
ames: larva: drain
ames: metamorphosis
```

Ames can shed its larval form after clearing the queue.

```hoon
ames: czar zod.urbit.org: ip .35.247.119.159
; ~zod is your neighbor
; ~marzod is your neighbor
~latwel_marzod:dojo>
```

It then makes contact with the sponsor's galaxy `~zod`.  Your sponsor is identified as being able to communicate with you.  Finally, you have a responsive Dojo prompt.

- Optional Reading:  [Joe Bryan, "Annotation on the Boot Process"](https://groups.google.com/a/urbit.org/g/dev/c/ESrqJb3Ol54/m/bns0S1QkBAAJ)

![](../img/30-header-titan-5.png){: width=100%}
