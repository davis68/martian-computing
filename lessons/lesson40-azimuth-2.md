#   Azimuth II

![](../img/40-header-mars-0.png){: width=100%}

##  Learning Objectives

-   Explain the application of keys from the Urbit Hierarchical Deterministic (Urbit HD) wallet.
-   Explain how Bridge works with Azimuth PKI.


Formally, Azimuth provides the following services:

- “**Azimuth**: contains all on-chain state for azimuth. Most notably, ownership and public keys. Can't be modified directly, you must use the Ecliptic.
- “**Ecliptic**: is used as an interface for interacting with your points on-chain. Allows you to configure keys, transfer ownership, etc.
- “**Polls**: registers votes by the Galactic Senate on proposals. These can be either static documents or Ecliptic upgrades.
- “**Linear Star Release**: facilitates the release of blocks of stars to their owners over a period of time.
- “**Conditional Star Release**: facilitates the release of blocks of stars to their owners based on milestones.
- “**Claims**: allows point owners to make claims about (for example) their identity, and associate that with their point.
- “**Censures**: simple reputation management, allowing galaxies and stars to flag points for negative reputation.
- “**Delegated Sending**: enables network-effect like distributing of planets.
- “**Planet Sale**: gives an example of a way in which stars could sell planets on-chain.”

These are mostly operated through the Bridge client.


##  Urbit HD Wallet

![](../img/40-header-mars-1.png){: width=100%}

You own your Urbit.  But how can you verify this to others?  And can you allow others to operate your services without betraying your ownership keys?  The answers lie in the operations of Azimuth and Jael.  `%jael` was already discussed in Arvo I, where its role as a secret keeper was outlined.

Azimuth recognizes the Urbit Hierarchical Deterministic (HD) wallet, which stores sets of keys allowing certain operations to take place.

![](https://media.urbit.org/fora/proposals/UP-8.jpg){: width=75%}

The most important of these are:

- the _ownership key_, which establishes your ownership of an Ethereum address (typically via a Master Ticket or Metamask)
- the _management proxy_, which allows someone to configure network keys and manage sponsorship
- the _voting proxy_, which allows a galaxy to delegate voting
- the _spawn proxy_, which permits someone to create new daughter identities on your behalf

The management and spawn proxies are useful for hosting planet services or selling points.

- Reading: [Tlon Corporation, "Urbit HD Wallet"](https://urbit.org/docs/glossary/hdwallet/)
- Reading: [Anthony Arroyo `~poldec-tonteg`, Will Kim `~hadrud-lodsef`, Morgan Sutherland `~hidrel-fabtel`, "UP8:  Urbit HD wallet"](https://github.com/urbit/proposals/blob/master/008-urbit-hd-wallet.md)
- Reading: [Tlon Corporation, "Wallet-Generator"](https://urbit.org/docs/glossary/wallet-generator/)

<!--
  the management proxy is an HD wallet unto itself, so it actually has several private keys. the one we use for urbit ID stuff is at the HD path m/44'/60'/0'/0/0
-->


##  Bridge

![](../img/40-header-mars-2.png){: width=100%}

[Bridge](https://github.com/urbit/bridge) is the premier service for manipulating the Azimuth PKI.  Bridge provides the following services:

- manage sponsors and proxies
- spawn daughter points
- transfer ownership
- rekey a ship (move to a new Ethereum address)

Bridge interacts with Azimuth via Ecliptic contracts, Ecliptic being the point management contract for Urbit.

- Resource: [Azimuth PKI](https://github.com/urbit/azimuth)
- Resource: [Bridge](https://github.com/urbit/bridge)

### Ethereum Contracts

You should review the core contracts, which are written in [Solidity](https://solidity.readthedocs.io/en/v0.7.4/) for the Ethereum Virtual Machine.

[`azimuth-js`](https://github.com/urbit/azimuth-js) provides a number of tools for managing transfers; for instance, transfers are initiated from [`Admin/AdminTransfer`](https://github.com/urbit/bridge/blob/master/src/views/Admin/AdminTransfer.js) and accepted in [`AcceptTransfer`](https://github.com/urbit/bridge/blob/master/src/views/AcceptTransfer.js)

If you are interested in further details, there has been extensive discussion of how to access and manage contracts automatically or manually on the `urbit-dev` mailing list.

- Reading: [Azimuth contract](https://github.com/urbit/azimuth/blob/master/contracts/Azimuth.sol)
- Reading: [Ecliptic contract](https://github.com/urbit/azimuth/blob/master/contracts/Ecliptic.sol)


##  The Future of Azimuth

![](../img/40-header-mars-3.png){: width=100%}

There has been some dissatisfaction with the Ethereum substrate which Azimuth currently uses.  Since Azimuth is a public-key infrastructure that is only operated by Ethereum, it is possible and may become desirable to move Azimuth to a different platform, perhaps onto Urbit itself someday.

“Any Urbit PKI must fulfill a minimal set of requirements:

- “Must prevent double-spending of assets
- “Must have a globally-consistent state
- “Must have data availability of the full PKI state
- “Must have cheap enough transactions to allow user onboarding and maintenance
- “Must have interoperability with other blockchains so as to allow trustless atomic swaps of Urbit assets for digital currencies
- “Must have high enough throughput to support Urbit’s use-cases
- “Must have a protocol, social or technological, for upgrading the PKI ruleset”

There have been a number of proposals in this direction, such as “planetoids” (tracked off-chain by sponsoring stars), batched transactions, etc.

- Optional Reading: [Ted Blackman `~rovnys-ricfer`, Logan Allen, "Proof of Authority Urbit PKI"](https://gist.github.com/belisarius222/41998e569fe741ab0e1ffd98ec92b6f9)
