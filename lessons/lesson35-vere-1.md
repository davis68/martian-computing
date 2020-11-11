#   Vere I

![](../img/35-header-comet-0.png){: width=100%}

##  Learning Objectives

- Understand how Nock is instrumented on top of Unix processes as a virtual machine.
- Distinguish king and serf responsibilities.


##  The Binary Executable

![](../img/35-header-comet-1.png){: width=100%}

Urbit is a virtual machine running on a host OS.  In practice, this means that there must be a substrate:  an implementation which executes Nock into machine instructions, manages memory, handles `%unix` events from Arvo, and so forth.

Vere serves as the reference C implementation of the Urbit binary.  (There is also a Haskell version, [King Haskell](https://groups.google.com/a/urbit.org/g/dev/c/9BAG1TbA3nI/m/lWFhr4C3BwAJ), available.)

From Cores:

> You can think of the binary as being like a VMWare or Virtual Box server, which holds all of the Urbit data in a single memory block called the loom.  OTAs live in the Urbit system software inside of that memory block.
>
> The worker or "serf" carries out Nock and jet computations for an Arvo-shaped noun.  The daemon or "king" maintains the event log and interacts with the outside world (via Ames, Eyre, etc.).

Nock implementations abound, but on their own they aren't instrumented to manage the entire subject efficiently.

So what does the binary do?  Let's take a look at the C code of Vere.  You will find it helpful to clone [the current Urbit repo](https://github.com/urbit/urbit/).  We will be examining the files in `pkg/urbit/vere`.

### Prolegomena

> `u3` is the C library that makes Urbit work.

As such, it is incumbent upon us to learn to speak u3 C.  It's a very particular style of C, including manual reference counting.  Mostly you only need to know it when composing jets, but as Vere uses it internally we need to venture forth.

Everything in Nock is a noun, which is either an unsigned integer or a cell.  Thus Vere need only process unsigned integers.  To combat the problem of underspecified C integer types, u3 `typedef`s standard values, which include:

```c
typedef uint32_t c3_w;   // word
typedef int32_t  c3_ws;  // signed word
typedef uint8_t  c3_y;   // byte
typedef int8_t   c3_ys;  // signed byte
typedef uint8_t  c3_b;   // bit
typedef uint8_t  c3_t;   // boolean
typedef uint8_t  c3_o;   // loobean
```

These yield internal structures for Vere that look like this:

```c
/* u3_hhed: http header.
*/
  typedef struct _u3_hhed {
    struct _u3_hhed* nex_u;
    c3_w             nam_w;
    c3_c*            nam_c;
    c3_w             val_w;
    c3_c*            val_c;
  } u3_hhed;
```

which corresponds to a less verbose, non-Hungarian C:

```c
/* header: http header.
*/
  typedef struct _header {
    struct _header* next;
    uint32_t        name;
    char*           name_array;
    uint32_t        value;
    char*           value_array;
  } header;
```

u3 conventions take a little while to get used to but the consistency of the C code is refreshing once you are.

- Reading: [Tlon Corporation, "u3:  Noun Processing in C"](https://github.com/urbit/urbit/blob/master/doc/spec/u3.md), section "c3:  C in Urbit"

### The King (`king.c`)

The king is responsible for implementing the actual event log that Arvo uses to establish state.  The actual state is tracked using the `u3_host` `struct`:

```c
/* u3_host: entire host.
*/
typedef struct _u3_host {
c3_w       kno_w;                   //  current executing stage
c3_c*      dir_c;                   //  pier path (no trailing /)
c3_c*      wrk_c;                   //  worker executable path
c3_d       now_d;                   //  event tick
uv_loop_t* lup_u;                   //  libuv event loop
u3_usig*   sig_u;                   //  signal list
u3_utty*   uty_u;                   //  linked terminal list
u3_opts    ops_u;                   //  commandline options
c3_i       xit_i;                   //  exit code for shutdown
u3_trac    tra_u;                   //  tracing information
void     (*bot_f)();                //  call when chis is up
} u3_host;                            //  host == computer == process
```

The main event loop runs as a [daemon](https://en.wikipedia.org/wiki/Daemon_%28computing%29) for handling Arvo events.  The main loop setup and process looks like this:

```c
/* u3_king_commence(): start the daemon
*/
void
u3_king_commence()
{
  u3_Host.lup_u = uv_default_loop();

  //  initialize top-level timer
  //
  uv_timer_init(u3L, &u3K.tim_u);

  //  start up a "fast-compile" arvo for internal use only
  //  (with hashboard always disabled)
  //
  sag_w = u3C.wag_w;
  u3C.wag_w |= u3o_hashless;

  u3m_boot_lite();

  //  boot the ivory pill
  //
  {
    u3_noun lit;

    if ( 0 != u3_Host.ops_u.lit_c ) {
      lit = u3m_file(u3_Host.ops_u.lit_c);
    }
    else {
      lit = u3i_bytes(u3_Ivory_pill_len, u3_Ivory_pill);
    }

    if ( c3n == u3v_boot_lite(lit)) {
      u3l_log("lite: boot failed\r\n");
      exit(1);
    }
  }

  //  run the loop
  //
  _king_loop_init();
  uv_run(u3L, UV_RUN_DEFAULT);
  _king_loop_exit();
}
```

`uv_run` is a service of [`libuv`](https://github.com/libuv/libuv) for asynchronous input and output processes.

`u3L` is a macro alias for `u3_Host.lup_u`, defined at the first line as the main loop.


### The Serf (`serf.c`)

The serf evaluates Nock and matches jets.  The worker-process state is:

```c
    /* u3_serf: worker-process state
    */
      typedef struct _u3_serf {
        c3_d             key_d[4];          //  disk key
        c3_c*            dir_c;             //  execution directory (pier)
        c3_d             sen_d;             //  last event requested
        c3_d             dun_d;             //  last event processed
        c3_l             mug_l;             //  hash of state
        c3_o             pac_o;             //  pack kernel
        c3_o             rec_o;             //  reclaim cache
        c3_o             mut_o;             //  mutated kerne
        u3_noun          sac;               //  space measurementl
      } u3_serf;

```

For instance, the serf processes an event thus:

```c
/* u3_serf_work(): apply event, producing effects.
*/
u3_noun
u3_serf_work(u3_serf* sef_u, c3_w mil_w, u3_noun job)
{
  c3_t  tac_t = ( 0 != u3_Host.tra_u.fil_u );
  c3_c  lab_c[2056];
  u3_noun pro;

  // XX refactor tracing
  //
  if ( tac_t ) {
    u3_noun wir = u3h(u3t(job));
    u3_noun cad = u3h(u3t(u3t(job)));

    {
      c3_c* cad_c = u3m_pretty(cad);
      c3_c* wir_c = u3m_pretty_path(wir);
      snprintf(lab_c, 2056, "work [%s %s]", wir_c, cad_c);
      c3_free(cad_c);
      c3_free(wir_c);
    }

    u3t_event_trace(lab_c, 'B');
  }

  //  %work must be performed against an extant kernel
  //
  c3_assert( 0 != sef_u->mug_l);

  pro = u3nc(c3__work, _serf_work(sef_u, mil_w, job));

  if ( tac_t ) {
    u3t_event_trace(lab_c, 'E');
  }

  return pro;
}
```

I recommend perusing the files of `pkg/urbit` more generally to get a feel for how things interrelate, including the `include` header files.

Jet code is matched against `tree.c`; we will examine this later on.

![](../img/35-header-comet-2.png){: width=100%}
