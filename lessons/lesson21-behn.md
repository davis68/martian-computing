#   Behn

![](../img/21-mccall-0.png)

##  Learning Objectives

-   Understand the high-level architecture and API of Behn.
*   Lab:  Produce a stopwatch app using the Behn API.


##  “A Horse, A Horse, My Kingdom for a Horse!”

Behn is simple.  Behn is a timer.  Yes, an entire vane for a timer.

> Behn … allows vanes and applications to set and timer events, which are managed in a simple priority queue.

Behn is not the most critical vane (in a sense), but it is the smallest vane and thus a really good example to figure out what constitutes a vane.  Behn has to deal with state a lot, clearly.

> It allows vanes and applications to set and timer events, which are managed in a simple priority queue.  `%behn` produces effects to start the unix timer, and when the requested `%behn` passes, Unix sends wake events to %behn, which time routes back to original sender.  We don't guarantee that a timer event will happen at exactly the `%behn` it was set for, or even that it'll be particularly close.  A timer event is a request to not be woken until after the given time.


##  Vane Arms

Behn exposes five arms to call from Arvo:

```hoon
|%
++  call  :: handle a +task:able:behn request
++  load  :: migrate an old state to a new behn version
++  scry  :: view timer state
++  stay  :: return state
++  take  :: produce a `%wake` event (only Behn gift)
```

`++call` talks to the `event-core` core which initiates a wait.  Each call requires a token, which may be one of the following:

```hoon
%wait  :: set a new timer and adjust unix wakeup
%wake  :: wake up after corresponding event
%huck  :: give back immediately
%born  :: urbit restarted; refresh then store wakeup timer duct
%rest  :: cancel the timer and adjust unix wakeup
```

(There are a few more which deal with failures, kernel upgrades, etc.)

It is instructive to see how `++wait` works.  The entire arm is a single gate:

```hoon
++  wait  |=(date=@da set-unix-wake(timers.state (set-timer [date duct])))
```

Let's refactor that to make it clearer to scan:

```hoon
++  wait
  |=  [date=@da]
  =/  timer-value  (set-timer [date duct])
  set-unix-wake(timers.state timer-value)
```

`++set-timer` is the arm which adds a timer to Behn's state.  `++set-unix-wait` then monitors the list of Unix wakeup timers.

A Gall call to `%behn` looks like this:

```hoon
[%pass /egg-timer %arvo %b %wait (add now.bowl t)]~
```

This call consists of a `%pass` token, a `wire` source address, messaged to `%arvo`'s `%b` (Behn) vane at the `%wait` arm with appropriate noun.  The move proper will be more concise:  recall `[cause effect]`, er, `[bone card]`; thus, `[/egg-timer [%wait time]]` or similar.

Behn is used commonly in the kernel to maintain the system state, in particular in Clay:

> `%eyre` uses `%behn` for timing out sessions, and `%clay` uses `%behn` for keeping track of time-specified file requests.

- Reading: [Tlon Corporation, "Behn Tutorial"](https://urbit.org/docs/tutorials/hoon/hoon-school/behn/)
- Reading: [`behn.hoon`](https://github.com/urbit/urbit/blob/master/pkg/arvo/sys/vane/behn.hoon)

![](../img/21-mccall-1.png)

_All art by Robert McCall._


#   Questions

##  A Minimalist Gall App

Return again to the [`egg-timer` app tutorial](https://urbit.org/docs/tutorials/hoon/hoon-school/egg-timer/).

You may start the Gall app using `|start %egg-timer` and poke it using a relative time such as `:egg-timer ~s10`.

Modify the app so that instead of printing a simple `~&` message when the timer goes off, it outputs a timestamp (in absolute time) of the current time, either as `@da` or as a `date` (see [`++yore`](https://urbit.org/docs/reference/library/3c/#yore)).
