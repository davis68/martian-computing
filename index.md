#   CS 498MC • Martian Computing
#### Neal Davis • Department of Computer Science • University of Illinois

![](./img/mars-landscape-hero.png)

The underlying infrastructure of modern networked computing—namely Unix and its derivatives—is approaching fifty years of age.  What will come to replace it?  A strong competitor is the clean-slate “operating function” approach of Urbit.  Jocosely branded as “computing for Martians,” Urbit provides a fresh and updated vision of what Internet computing could come to look like in future years.  Featuring end-to-end encryption and true peer-to-peer routing built on a network-first operating system, Urbit fosters decentralized digital societies and stable user identities.

Our primary objectives in this course are for you to be able to explain and navigate the technical layout of Urbit, as well as construct novel applications for Arvo, the Urbit operating function, using the Hoon programming language.

- Understand the schematics and technical implementation of the Urbit OS kernel (Arvo and vanes).
- Navigate and utilize the Urbit ID public-key infrastructure (Azimuth).
- Program literately using the Hoon language, including source code conventions and interoperability.
- Construct userspace apps to run on the Urbit OS platform (Gall, Landscape).


##  Audience

My target audience for the course consists of graduate students and seniors in computer science and neighboring fields interested in sound computing and functional operating system design (functional-as-in-language).  The course assumes an interest in functional programming but no specific experience[.](https://en.wikipedia.org/wiki/Centzon_T%C5%8Dt%C5%8Dchtin)  <!-- egg -->


##  Resources

| What                 | When and Where |
| -------------------- | -------------- |
| **Instructor email** | [cs498mcadmin@illinois.edu](mailto:cs498mcadmin@illinois.edu?subject=CS498MC) |
| **Class URL**        | [go.illinois.edu/cs498mc](https://go.illinois.edu/cs498mc) |
| **Class forum**      | `~magbel/martian-computing` |


##  Access

![](./img/mars-pathfinder-hero.png)

The use of Urbit requires an [Urbit ID](https://urbit.org/using/install/).  You can purchase an ID on a third-party site like [urbit.live](https://urbit.live) or [OpenSea](https://opensea.io/).  You can also use a transient ID (called a "comet") as a permanent ID; these are free and can be generated on your own machine.


##  Agenda

![](./img/mars-olympus-mons-hero.png)

Lessons focus on conceptual or architectural aspects of Urbit, including technical discussions of Urbit’s behavior and internals.  Labs are hands-on tutorials to familiarize students with operations and language features.

| Wk | Date | Number | Lecture | Lab | MP |
| -- | ---- | ------ | ------- | --- | -- |
| 0 | 08/26 | 00 | [Prospectus](./lessons/lesson00-prospectus.md) |  |  |
|  | 08/28 | 01 | [Dojo](./lessons/lesson01-dojo.md) |  |  |
| 1 | 08/31 | 02 |  | [Azimuth I](./lessons/lesson02-azimuth-1.md) |  |
|  | 09/02 | 03 | [Generators](./lessons/lesson03-generators.md) |  |  |
|  | 09/04 | 04 | [Auras](./lessons/lesson04-aura.md) |  |  |
| 2 | 09/09 | 05 | [Syntax](./lessons/lesson05-syntax.md) |  |  |
|  | 09/11 | 06 | [Cores](./lessons/lesson06-cores.md) |  | `mp0` |
| 3 | 09/14 | 07 |  | [`%say` Generators](./lessons/lesson07-say-generators.md) |  |
|  | 09/16 | 08 | [Subject-Oriented Programming](./lessons/lesson08-subject-oriented-programming.md) |  |  |
|  | 09/18 | 09 | [Clay I](./lessons/lesson09-clay-1.md) |  |  |
| 4 | 09/21 | 10 |  | [Libraries](./lessons/lesson10-libraries.md) |  |
|  | 09/23 | 11 | [Ford I](./lessons/lesson11-ford-1.md) |  |  |
|  | 09/25 | 12 | [Debugging Hoon](./lessons/lesson12-debugging.md) |  | `mp1` |
| 5 | 09/28 | 13 |  | [`%ask` Generators](./lessons/lesson13-ask.md) |  |
|  | 09/30 | 14 | [Types & Molds](./lessons/lesson14-typechecking.md) |  |  |
|  | 10/02 | 15 | [Standard Library](./lessons/lesson15-stdlib.md) |  |  |
| 6 | 10/05 | 16 |  | [Common Containers](./lessons/lesson16-containers.md) |  |
|  | 10/07 | 17 | [Gall I](./lessons/lesson17-gall-1.md) |  |  |
|  | 10/09 | 18 | [Kernel](./lessons/lesson18-kernel.md) (Chat with `~rovnys-ricfer`) |  | `mp2` |
| 7 | 10/12 | 19 |  | [Data & Text Parsing](./lessons/lesson19-text-parsing.md) |  |
|  | 10/14 | 20 | [Ames](./lessons/lesson20-ames.md) |  |  |
|  | 10/16 | 21 | [Behn](./lessons/lesson21-behn.md) |  |  |
| 8 | 10/19 | 22 |  | [Clay II](./lessons/lesson22-clay-2.md) |  |
|  | 10/21 | 23 | [Polymorphism](./lessons/lesson23-polymorphism.md) |  |  |
|  | 10/23 | 24 | [Urbit Foundation](./lessons/lesson24-foundation.md) (Chat with `~wolref-podlex`) |  | `mp3` |
| 9 | 10/26 | 25 |  | [Gall II](./lessons/lesson25-gall-2.md) |  |
|  | 10/28 | 26 | [Gall III](./lessons/lesson26-gall-3-landscape.md) |  |  |
|  | 10/30 | 27 | Buffer |  |  |
| 10 | 11/02 | 28 |  | [Eyre & Iris](./lessons/lesson28-eyre-iris.md) |  |
|  | 11/04 | 29 | [Gall IV](./lessons/lesson29-gall-4-communication.md) |  |  |
|  | 11/06 | 30 | [Boot Process](./lessons/lesson30-boot-process.md) |  | `mp4` |
| 11 | 11/09 | 31 |  | [CLI](./lessons/lesson31-cli.md) |  |
|  | 11/11 | 32 | [Arvo I](./lessons/lesson32-arvo-1.md) |  |  |
|  | 11/13 | 33 | [Hoon I](./lessons/lesson33-hoon-1.md) |  |  |
| 12 | 11/16 | 34 |  | [Hoon II](./lessons/lesson34-hoon-2.md) |  |
|  | 11/18 | 35 | [Vere I](./lessons/lesson35-vere-1.md) |  |  |
|  | 11/20 | 36 | [Vere II](./lessons/lesson36-vere-2.md) |  | `mp5` |
| 13 | 11/30 | 37 |  | [Arvo II](./lessons/lesson37-arvo-2.md) |  |
|  | 12/02 | 38 | [Nock I](./lessons/lesson38-nock-1.md) |  |  |
|  | 12/04 | 39 | [Nock II](./lessons/lesson39-nock-2.md) |  |  |
| 14 | 12/07 | 40 |  | [Azimuth II](./lessons/lesson40-azimuth-2.md) |  |
|  | 12/09 | 41 | [Final Thoughts](./lessons/lesson41-final-thoughts.md) |  |  |
|  | 12/11 |  |  |  | `mp6` |
