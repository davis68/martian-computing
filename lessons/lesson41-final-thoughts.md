#   Launchpad

![](../img/41-header-earthrise.png){: width=100%}

##  Learning Objectives

-   Wrap things up neatly.

> My instinct was always that Urbit's delivery schedule should be as long as possible. For me, there are always two Urbits: the Urbit that exists, and the Urbit that should exist. To invent the latter I have to inhabit it. When I look at the present, I try as hard as possible to look at it from the perspective of the future – that's where my head should be. (Yarvin, “A Founder's Farewell”)

We made it through.

We made it through the whole muddy course and laid eyes at last on the shiny Nock crystal at the center.  (I think Urbit is more like [Jupiter](https://en.wikipedia.org/wiki/Jupiter#Internal_structure) than Mars!)

How do we think about Urbit, moving forward, and more importantly, what can we take away from this study that will benefit our future software development?

![](https://i.makeagif.com/media/5-02-2017/QEn_Io.gif){: width=50%}

APL developer Aaron Hsu addressed the issue of what he called "programming churches" (coherent schools which can inculcate development practices for the non-hero programmer) as well as affordances, in his 2020 LambdaConf talk, "Modern APL in the Real World:  Theory, Practice, Case Studies".  His claim is that software communities only succeed if they create the environment where good code production can flourish.  "This [social and psychological aspects] is the most institutionalized incompetency in the programming community."  Urbit as a community is entering upon this phase as the closed Tlon kernel development process opens and begins to flower into an active developer community centered on the Urbit Foundation.

Let's start by covering what I think is still missing from your education.  We'll then discuss the Urbit project and its place in the Internet ecosystem today.


##  What Else

The kernel is small but rich, and there are some topics we didn't cover yet:

- `graph-store`
- [the API](https://urbit.org/using/integrating-api/)
- end-to-end jet composition
- binary/Vere work (like optimization or a bug fix)
- the King Haskell binary
- actual work on Azimuth, like automation of spawning a planet or hosting
- using Aqua to instrument a fleet of test ships
- code performance profiling

The Tlon team has released [a developer's guide](https://urbit.org/using/develop/) with a good outline of how to think about development on and with Urbit.

You have a solid foundation now to sally into kernel development, application development, or to just use Urbit's `graph-store` as a third-party backend database.


##  Competitors

> To put it a slightly different way, Web APIs are the I/O of a modern cloud computer. Existing programming environments aren't designed first and foremost for driving this I/O channel. A new environment needs to be -- so this is the focus we're working toward right now.  (Yarvin, [AMA](https://old.reddit.com/r/IAmA/comments/4bxf6f/im_curtis_yarvin_developer_of_urbit_ama/))

Competition abounds for each of the things that Urbit seeks to accomplish.  I have been able to identify the following projects which have some overlap with Urbit's intent.  None of them unify the concepts as extensively as Urbit, however.

- Identity Protocols
    - Identity management
        - [DID](https://w3c.github.io/did-core/)
        - [Sovrin](https://sovrin.org/)
        - [3Box](https://www.3box.io/)
    - Decentralized access control
        - Nucypher
- Data Protocols
    - Content-addressable storage
        - [IPFS](https://ipfs.io/)
        - [Textile](https://textileio.github.io/js-threads/)
    - [CRDT](https://martin.kleppmann.com/2017/04/24/json-crdt.html)
        - [Automerge](https://github.com/automerge/automerge)
    - Data synchronization protocols
        - [Braid](https://datatracker.ietf.org/doc/draft-toomim-braid/)
    - Data-ownership protocols
        - [Solid](https://solid.mit.edu/)
        - [Perkeep](https://perkeep.org/)
        - [Maidsafe](https://maidsafe.net/)
    - Linked data
        - RDF
        - [Semantic Web](https://www.w3.org/standards/semanticweb/)
        - Xanadu
    - P2P file sharing
        - Bittorrent
    - P2P databases
        - Gun
        - OrbitDB
    - P2P communication protocols
        - Matrix
        - SSB
        - ActivityPub
- Computing Protocols
    - Universal computing engine
        - [WebAssembly](https://webassembly.org/)
    - Trustless computing
        - Golem
        - Truebit
    - Mesh networking
        - Yggdrasil
        - Cjdns
    - Blockchain
        - Ethereum
    - Code collaboration
        - Radicle
    - Decentralized DNS
        - ENS
        - Handshake
    - Refactored functional programming platforms
        - [Red](http://www.red-lang.org/)
- Experience Protocols
    - Privacy-focused networking
        - Tor
        - i2p
    - Ad-free browsers
        - Brave
        - Beaker

Some of these compete directly with aspects of Urbit, such as Sovrin.  Others could work quite compatibly, such as Bittorrent and IPFS.  It's easy to imagine a payment processor interface on an Urbit, or an IPFS interface with Clay.


##  Systematic Critiques

(I ask these questions for discussion, but defer my own opinion on them.)

- **Does Urbit actually bring computing to the people?**

    > Once you have a system whose state is deterministically generated purely from input events, you can mitigate the Trusting Trust attack by verifying that different interpreters calculate the exact same state from the same sequence of input events. Because it is so small and simple because it is "tiny and diamond-perfect", any motivated college student should be able to write their own compatible interpreter instead of relying on one built by others, like the aspirations of the Cypherpunks of old. Contrast this to something like the JVM, whose size and complexity make construction of amateur runtimes infeasible.

- **Is Urbit too hard to use?**

    How many people can write large programs in Urbit?  How many should be able to?

- **Does Urbit recreate the issues involved with net neutrality?**

- **Does Urbit solve dependency hell?**

    It's too early to say, particularly without a package manager, but the history of vanes like Ford indicate that the ethos of refining code via major refactors is alive and thriving.  Furthermore, OTAs at least must be atomic, which also establishes a precedent for userspace software once distributed.  In an Urbit-dominant world, you'll also interact with services rather than

- **Is Urbit fast enough?**

    Hmm.  Richard Gabriel, in speaking of Scheme, wrote, "The right thing takes forever to design, but it is quite small at every point along the way. To implement it to run fast is either impossible or beyond the capabilities of most implementors."

    There are actually two problems here:

    1. Urbit binary
    2. Urbit network

- **Can Urbit work or is it, in fact, [performance art](https://hackernews.antonhalim.com/item/23034608)?**

    Is Urbit a cult?  Is it a Ponzi scheme?  Or is it a deft thrust into the heart of what made the Internet so attractive in the first place before megacorps and censors took over?

Will Urbit rise like the ARPANET or fall like Xanadu?  To really pull this off, Urbit will have to become equivalent to blogging, tweeting, Reddit/forums, Facebook/social media, GitHub, email, and markets/auctions.  That's no small task, but many of the building blocks are in place.  What Urbit still lacks is the killer app that makes it indispensable to everyone and initiates a preference cascade.

- Reading: [Richard Gabriel, "The Rise of Worse is Better"](https://www.dreamsongs.com/RiseOfWorseIsBetter.html)
- Reading: [Dawid Ciężarkiewicz, "Pragrammatic Critique of Urbit" (_sic_)](https://dpc.pw/pragrammatic-critique-of-urbit)
- Reading: [Galen Wolfe-Pauly `~ravmel-ropdyl`, "The Digital Archipelago: How to Build an Internet Where Communities Thrive" (_Coindesk_)](https://www.coindesk.com/how-to-build-an-internet-where-communities-thrive)
- Reading: [François-René Rideau (Faré), "Houyhnhnms vs Martians"](https://ngnghm.github.io/blog/2016/06/11/chapter-10-houyhnhnms-vs-martians/)
- Reading: [Curtis Yarvin `~sorreg-namtyv`, "Common Objections to Urbit"](https://urbit.org/blog/common-objections-to-urbit/)
- Optional Reading: [Yuri de Gaia, "How to Improve Urbit With Federated Side-Chains"](https://degaia.co/how-to-improve-urbit-with-federated-side-chains/)
- Optional Reading: [Erik Newton `~patnes-rigtyn`, "Urbit for Normies"](https://urbit.org/blog/urbit-for-normies/)
- Optional Reading: ["zer0ver"](https://0ver.org/)
- Optional Reading: [Jeff Atwood, "_Showstopper!_"](https://blog.codinghorror.com/showstopper/)
- Optional Reading: [Isaac Simpson, "Urbit and the Not-So-Dark Future of the Internet"](https://medium.com/vandal-press/urbit-and-the-not-so-dark-future-of-the-internet-400c9b667e2)
- Optional Reading: [Andrea O'Sullivan, "Can Urbit Reboot Computing?" (_Reason_)](https://reason.com/2016/06/21/can-urbit-transform-the-internet/)
- Optional Reading: [Ian Bicking, “I think I finally understand what Urbit is” (Twitter)](https://twitter.com/ianbicking/status/1249862161758916609)
- Optional Reading: [Tlon Corporation, “Martian Computing”](https://web.archive.org/web/20140424223249/http://urbit.org/community/articles/martian-computing/)


##  Parting Remarks

[![Life on Mars](http://img.youtube.com/vi/AZKcl4-tcuo/0.jpg)](https://www.youtube.com/watch?v=AZKcl4-tcuo "Life on Mars")

What do you take away from the Urbit project?  If it fails to achieve its own goals, what broader lessons about software development, community formation, and systems design can be learned and ported to future endeavors?

I don't know if Urbit is "the" fix to our systemic technical governance problems.  I think it's a reasonable bet, and the core values of privacy, data ownership, and identity are all dear to me[.](https://en.wikipedia.org/wiki/Church_of_the_SubGenius)

Urbit is of a kind with Bitcoin and other technologies adjacent to crypto-anarchism, cypherpunks, Extropianiasm, and other movements of technocratic hope.  I share many of those hopes myself, of leveraging our technology to increase human freedom rather than to corral it, mine it, and merchandise it.  You now know enough, at least, to judge for yourselves how well Urbit contributes to such a vision.

- Reading: [Eric Hughes, "The Cypherpunk Manifesto"](https://www.activism.net/cypherpunk/manifesto.html):  “Cypherpunks write code.”
- Reading: [Timothy May, "The Crypto Anarchist Manifesto"](https://www.activism.net/cypherpunk/crypto-anarchy.html)
- Optional Reading: [Neal Stephenson, _Cryptonomicon_](https://en.wikipedia.org/wiki/Cryptonomicon)

I close with an image of the Apollo 10 command module in orbit around the Moon in 1969.  To me, this is the single most hopeful and powerful image from all of human history:  the certainty that we can build outwards and onwards forever.

![](../img/41-header-apollo-x.png){: width=100%}
