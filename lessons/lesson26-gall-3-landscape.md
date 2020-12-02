#   Gall III:  Landscape

![](../img/26-header-nebula-0.png){: width=100%}

##  Learning Objectives

-   Understand how static Gall instruments a Landscape tile.
*   Lab:  Produce a basic Landscape tile.


##  Landscape

Landscape is a browser-facing Gall agent and its concomitant Javascript components.  As a platform, it is among the more complex components of userspace.

> Landscape is a graphical web interface for your ship.  Right now, Landscape allows for social networking functions, such as participating in IRC-like chats, subscribing to forum-like pages of other ships, and messaging other ships directly.  It also has weather and clock apps.  Landscape is an alternative messaging interface to the command-line app Chat.

Landscape is a proof of concept for a world beyond the command line.  It has since become the primary interface for many, probably most, users.

![](https://media.urbit.org/site/posts/essays/landscape-a-portrait-1.png){: width=100%}

_The 2019 Landscape landing page._

![](https://blog.vaexperience.com/wp-content/uploads/2020/03/urbit-os.png){: width=100%}

_The 2020 OS1 Landscape landing page._

- Optional Reading: [Matilde Park `~haddef-sigwen`, "Landscape:  A Portrait"](https://urbit.org/blog/landscape-a-portrait/)
- Optional Reading: [Galen Wolfe-Pauly `~ravmel-ropdyl`, "The State of Landscape"](https://urbit.org/blog/the-state-of-landscape/)

### Examples

Besides the built-in agents like Chat and Publish, there have been a number of community contributions recently:

- [Jose `~norsyr-torryn` (`yosoyubik`), `canvas` Group Drawing App](https://github.com/yosoyubik/canvas)
- [Luke Champine `~watter-parter`, `rote` Flashcard App](https://github.com/lukechampine/rote), particularly [the line-by-line explanation](https://github.com/lukechampine/rote/blob/master/urbit/app/rote.hoon)
- [`~littel-wolfur`, `srrs` Spaced Repetition Repetition System](https://github.com/ryjm/srrs)
- [Pyry Kovanen `~dinleb-rambep`, Books](https://github.com/pkova/urbit/tree/books/pkg/interface/books)
- [John Franklin `~dirwex-dosrev`, Notes](https://github.com/jfranklin9000/notes/)

### Operations

Landscape uses a React-derived [Indigo](https://github.com/urbit/indigo-react) framework front-end.  (This implements [Tlon's design language](https://www.figma.com/community/file/822953707012850361).)

You'll have something like the following file structure when building a Landscape app:

```bash
.
├── app
│   ├── myapp.hoon
│   └── myapp
│       ├── css
│       │   └── index.css
│       ├── index.html
│       └── js
│           ├── index.js
│           └── tile.js
├── lib
│   └── myapp.hoon
├── sur
|   └── myapp.hoon
└── tests
    └── myapp.hoon
```

depending on which components you need to implement.

Since React is a JS framework, it will generate a lot of the necessary code already and you won't have to do very much JS programming to get things to work.  For instance, the entire `index.js` file could look like this:

```js
import React from 'react';
import ReactDOM from 'react-dom';
import { Root } from './js/components/root.js';
import { api } from './js/api.js';
import { subscription } from "./js/subscription.js";

import './css/indigo-static.css';
import './css/fonts.css';
import './css/custom.css';

api.setAuthTokens({
  ship: window.ship
});

window.urb = new window.channel();

subscription.start();

ReactDOM.render((
  <Root />
), document.querySelectorAll("#root")[0]);
```

An event handler in your JS code could look like this:

```js
api.action('myapp', 'json', {myvalue: Number(this.state.value)});
```

and the state could be referred to as

```js
<p>{this.props.data.myvalue}</p>
```

If you work on Landscape apps, you'll need to make decisions regarding which parts of the state and logic should live in Gall and which in the browser.  Since you don't need to handle authentication and you have a database ready to hand, you also don't need to worry so much about storing session data like cookies.

So what's going on with all this Javascript?  Gall (Urbit in general, in fact) doesn't know about Javascript or your browser.  You can interact with your ship through certain formalized processes though.  In essence, JS is creating moves that get passed to Arvo/Gall the same way that other moves get handled internally.  The only difference is the outside world (other ship v. browser client).
