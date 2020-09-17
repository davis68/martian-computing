#   Clay 1

![](../img/09-header-stars-1.png){: width=100%}

##  Learning Objectives

-   Understand the high-level architecture of Clay.
-   Access file data from Clay.
-   Access arbitrary revisions of a file through Clay.
-   Manage multiple desks on a single ship.
-   Synchronize desks between two ships.

We are now pivoting from the basic structure and syntax that Urbit expects (from Hoon and Nock) to looking at Arvo itself, the Urbit OS.  Arvo is a single-threaded event interpreter and distributor.  Most of the action occurs in the vanes.  Events may arise from user input, network packets, or programs (apps, daemons, vanes).  Each event has a characteristic structure, which we will discuss later on in the Kernels lesson.

Arvo's vanes have changed somewhat as the core vision has been refined, but if you go back to the [Urbit whitepaper](http://media.urbit.org/whitepaper.pdf) you can find the antecedents of each of them.  In brief, the vanes are:

- **Ames** handles peer-to-peer networking over the UDP protocol.
- **Behn** handles system service timing.
- **Clay** acts as a version-controlled filesystem and data store.
- **Dill** is the terminal driver, handling keystrokes as input events.
- **Eyre** provides client-facing HTTP services.
- You will still see references to the former build vane **Ford**, but it has now been refactored into Clay.
- **Gall** provides the specifications for userspace applications including Landscape (the browser portal).
- The vane **Hall** is deprecated but provided chat services.
- **Iris** provides server-side HTTP services as counterpart to Eyre.
- **Jael** tracks Azimuth-related data such as sponsorship and networking keys[.](https://microship.com/behemoth-computer-history-museum/)  <!-- egg -->

Arvo itself conducts the dance among these vanes via structured events.  In essence, Arvo replaces the interpreter and the database of a server execution stack (again, see the Whitepaper, section "2.3 Arvo").  "Urbit is built with the explicit assumption that a perfectly reliable, low-latency, high-bandwidth log in the cloud is a service we know how to deliver. The log can be pruned at a reliable checkpoint, however.  … Interrupted calculations are either abandoned or replaced with an error. Since only completed events are logged, log replay terminates by definition."

We'll start by talking about Clay, because it's one of the really core elements of what Urbit is.  (You can imagine an Urbit without, say, Iris—but without Clay there'd be no Urbit at all.)

Our pattern with the bigger vanes like Clay and Gall will be to introduce a high-level overview in one lesson, then circle back around and get under the hood in subsequent lessons.  The smaller vanes (Ames, Behn) will merit at most only one lesson each.


##  The Architecture of Clay

Clay serves Arvo as a data store and filesystem (and, through the `+ford` arm, as a build system—see Ford 1).

What is a filesystem?  Well, an abstracted view is that it's a way of hierarchically mapping data stores.  Our terminology evolved directly from punchcard file boxes, and even today we speak of files and folders when we've long been removed from that contingency.

Older systems, like MS-DOS (and [FAT32](https://en.wikipedia.org/wiki/File_Allocation_Table#FAT32), still used on flash drives) had a file allocation table (FAT) which was basically a table of linked lists pointing to file clusters.  FAT-style filesystems have issues with fragmentation due to this structure.

Other modern systems like `ext4fs` instead leave padding around files so that there's room to grow them without needing to link disparate scattered clusters together.  NTFS, used for contemporary Windows systems, walks a middle road.

A distributed version-control system (DVCS) is itself a filesystem.  Git and friends are filesystems:  they just map back to Unix-style drives for non-cloud interactions.

Clay provides a hierarchical path-based system to locate files.  The "desk," or current branch, collects documents, applications, service files, logs, etc. into a standard structure analogous to that of Unix-derived systems:

- `app/` contains primarily userspace application files.
- `gen/` contains generators, user-composed and otherwise.
- `lib/` contains libraries (imported by `/+`).
- `mar/` contains marks, discussed subsequently.
- `ren/` contains rendered documents.
- `sur/` contains structures (imported by `/-`).
- `sys/` contains Arvo.
- `ted/` contains blockchain services.
- `tests/` contains unit tests for use by Ford.

These can be mirrored to the Unix file system, and at this point frequently are if one is developing code or posting content.

Clay is a single-level store, meaning that it stores all persistent state in a single binary tree.  (Sigh and dully repeat, "Everything in Urbit is a binary tree.")  For Urbit, that's all that needs to be seen:  the host OS may be using RAM, swap, flash memory, whatever it needs.

Clay features referential transparency and typed data.  (If the idea of a typed version-control filesystem doesn't get your blood pumping, I don't know what to tell you.)

For Clay, _referential transparency_ means “a request must always yield the same result for all time.”  Referential transparency is also [defined by Wikipedia](https://en.wikipedia.org/wiki/Referential_transparency) as the property in which “an expression … can be replaced with its corresponding value without changing the program's behavior.”  Pure functions have this property, and functional languages prize it.  Imperative programming techniques can and frequently do produce situations in which the "same" function call yields different results.

As far as the concept of _typed data_ goes, Clay attaches identification tags to any data and has ready to hand a set of conversion routines appropriate to the data type.  These ID tags are called "marks," and they act like MIME types.  (You should get used to divorcing the conceptual relationship of data—what we could call it's _form_ in the Platonic sense—from it's _representation_ or _instantiation_.  For instance, one writes a JSON file a certain way in text, but when parsing it needs to think about it at a higher level of abstraction.)

Whereas a DVCS filesystem like Git has special rules for handling text v. binary blob elements, Clay encourages the use of marks to identify filesystem data type and conversion routines.  “It's best defined as a symbolic mapping from a filesystem to a schema engine.”  We'll deal more with marks and conversions below.

Clay stores information in the blob (not to be confused with binary blob), a cohesive collection of deduplicated data.  The filesystem tree is actually a collection of hashes, where the hashes are pointers into the blob.

- Reading: [Curtis Yarvin `~sorreg-namtyv`, "Towards a New Clay"](https://urbit.org/blog/toward-a-new-clay/)
- Optional Reading: [Tlon Corporation, "Clay Tutorial"](https://urbit.org/docs/tutorials/arvo/clay/) (obsolete documentation, but the first few sections are quite useful)


##  Filesystem Coordination

You know the mechanics of coordinating your ship's contents with Unix; or at least, you saw this once way back when setting up your ship and fakezods.

```dojo
|mount %
```

A Clay path is of type `(list knot)` (what is this in other terms?).  This promotes the use of URL-safe characters, since only a sensible subset of ASCII characters are permitted.

Remember what a `beak` is, from `%say` Generators:  it is a three-element cell with faces `(p=ship q=desk r=case)`.  The beak prefaces any path because Clay is a global file system (see below).  Thus any file and revision on the entire global file system must have a unique path for access.

You can get this information in Dojo by typing `%`.  Thus, by calling `|mount` on `%`, you mount your current ship/desk/case to the Unix filesystem.  (Properly speaking, `%` is your current relative location on the desk.  You haven't had reason to refer to other locations yet, though.)

Unlike Unix (which assumes a relative path unless prefixed with `/`), Clay requires the use of `%` to specify a relative path.  Fear not, however:  you can avoid the need to type segments of your path over and over again by use similarity notation with `=`, which pattern-matches a segment of your path in the beak.  For instance, at the Dojo you can see the effect on the beak of your ship of copying the first and last components and replacing the desk in the middle:

```hoon
> /=kids=
[~.~lagrev-nocfep %kids ~.~2020.8.28..20.42.44..e384 ~]
```

The date is in there, recall, because Clay supports immutable references only.

To synchronize changes, you need to

```dojo
|commit %home
```

that is, refer to a particular desk to commit changes from the Unix-side filesystem back into Urbit.

(If you want to live a bit dangerously, you can `|autocommit %home`, which continuously monitors and synchronizes the `%home` desk and the filesystem.  This is frequently useful when developing code.)

Your ship has other desks as well, notably `%kids`.  You can see how to create and access other desks below (section "Desks").

- Reading: [Tlon Corporation, "Using Your Ship", section "Clay manual"](https://urbit.org/using/operations/using-your-ship/)


##  Accessing Files and Desks

![](../img/09-header-stars-2.png){: width=100%}

Clay, as I mentioned, is in fact a _global_ file system.  That is, if you have proper permissions to access the data in question, you can refer transparently to data on _anyone's_ ship.  The beak thus prefixes any path you refer to.  As `%` refers to your current location, you can refer to a file `/~sampel-palnet/home/web/output.txt` (in Unix terms) as `%/web/output/txt` (in Clay terms).

Locally, the simplest operation is to change your current working directory.  Here, use `+cat` to examine itself after moving to the `gen/` directory:

```hoon
=dir /=home=/gen
+ls %
+cat %/cat/hoon
```

`+ls` and `+cat` show you what Clay knows about (not the Unix-side files, the Clay-side files).  `+tree %` shows you the entire tree.

Writing a gate's output to a file is relatively straightforward from the Dojo using `*` as a redirect to a location in the current desk:

```hoon
*%/output/myresults/txt (add 1.500.000 (mul 2.000.000 2.000.000))
```

where `output` is a new directory inside of your pier.

For instance, the following code produces a list of all of the planets under a particular star:

```hoon
=p (turn (gulf 0x1 0xffff) |=(a/@ `@p`(cat 4 ~dopzod a)))
*%/output/planets/txt (turn p |=(a/@p (scot %p a)))
```

This is particularly desirable when large lists of tapes would clog the I/O routines.

Reading and writing files natively to Hoon is more complicated and we'll study it in depth in Clay 2.


### Revisions

Clay is a version-controlled filesystem.  This means that you can access prior versions of your files by version number

```hoon
+cat /=home/1/mar/json/hoon
```

where we are using similarity notation for the beak.

>If we're requesting a revision by label, then we simply look up the requested label in lab from the given dome. If it exists, that is our aeon; else we produce null, indicating the requested revision does not yet exist.
>
>If we're requesting a revision by number, we check if we've yet reached that number. If so, we produce the number; else we produce null.
>
>If we're requesting a revision by date, we check first if the date is in the future, returning null if so. Else we start from the most recent revision and scan backwards until we find the first revision committed before that date, and we produce that. If we requested a date before any revisions were committed, we produce 0.

You can tag a particular version of a desk using `|label`:

```hoon
|label %home release
```

Right now, this is typically used by developers for sharing Urbit system updates, but as you can imagine the possibilities are much broader and Git-like.

### Desks

You should think of desks as being like Git branches.  A desk is a parallel universe of your filesystem.

For historical reasons, tools like `+trouble` refer to a `%base` desk.  In contemporary Urbit systems, the `%base` desk is really your sponsor's `%kids` desk.  This serves as the reference version of your current filesystem.

Your `%home` desk includes all of the changes you have made locally.

Your `%kids` desk is a branch intended to service subsidiary points:  for a star, its planets; for a planet, its moons.

A new desk you create is like a Git branch:  it starts with the desk you are currently on, typically `%home`.  Besides fakezods, another way to handle software development on a live ship is to create a `%sandbox` desk.

```hoon
|merge %sandbox our %home
|mount /=sandbox=
```

I would consider this to be slightly less safe than a fakezod but significantly more useful once you start developing network-facing applications.

### Synchronization Across Ships

The most common reason for coordinating your ship with another is currently to receive over-the-air updates (OTAs).  Each planet receives from its parent star's `%kids` desk.  Moons would receive from the planet's `%kids` desk.  `|ota` and `|sync` are most commonly used and have their own semantics.

You may also want to have joint access to an operational feature, like sharing ownership of a group or notebook (blog/Publish) or chat.

### `scry`

Clay and Gall use a process called scrying to obtain read-only information.  The `.^` dotket rune reads a value from the appropriate namespace.  For instance, the following code tells Arvo to load a list of files in the `gen/` directory as a list.

```hoon
.^(arch %cy %/gen)
```

The general model for sharing files with other users is, at this time, architected around shared notebooks and chat channels.  This means that we're not prepared to talk about scry mechanics between ships until we've covered a reasonable amount of Gall.

- Reading: [Tlon Corporation, "Clay manual"](https://urbit.org/using/operations/using-your-ship/#clay-manual) (quickstart guide)

### Marks

Basic conversions are defined for many text-based types such as `txt` and `json`.  Mark conversions are handled with `.^` dotket and the `%cc` tag—so they're related to scrying.

Actual conversions are handled by the `++ford` arm of Clay (formerly the Ford vane).  We'll discuss the Ford builds and conversions more in Ford 1.

**HOWEVER**, there is a tendency in Urbit to represent data not in the plain-text form but in an abstracted form.  That is, consider XML.  There's a sense in which `<a b="c">d</a>` is just text, but the structure is inherent to it.  Any parser has to be able to pull the tag `a` with attribute `b` and content `d` into an internal representation.  Urbit operations frequently just live there, and since you only request data from Clay (rather than manipulating it _in situ_), this becomes an important distinction.  There's no guarantee that Clay stores JSON as a "text blob", only that it stores it in a JSON-compatible representation that trivially converts to other formats.

(There's also an interesting question inherent here about how to handle lossy conversions, such as JPEG or MP3 data.  These haven't been implemented as of this writing inside of Urbit.)


### Parting Remarks

Now, it's time to reframe everything in your basic working model of Clay-as-filesystem as a concession to Unix.  It's much better to not think of files at all:  you don't have files in Clay, you have nouns, which are binary trees of unsigned integers in hierarchy.

Clay serves as a single-level file store with no distinction between storage and memory.  All memory exported to Clay may be regarded as persistent.  This is critical to understanding Gall and the userspace apps when we come to that vane.

![](../img/09-header-stars-3.png){: width=100%}
