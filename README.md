#[Type4Fame](http://type4fame.com/)

[Type4Fame](http://type4fame.com/) is a multiplayer typing game havily inspired by typeracer.com but targeting a wider audience, a lot of cool gamification features, new game modes and ability to create your own public or private games. Get experience and money as you type, upgrade and buy new chars (not only cars, but superheroes, planes, rockets, robots, heroes from games and anime, etc.).

![Screenshot in Game](https://raw.github.com/cray0000/type4fame/master/public/img/screenshot_game.png "Screenshot in Game")
![Screenshot in Lobby](https://raw.github.com/cray0000/type4fame/master/public/img/screenshot_lobby.png "Screenshot in Lobby")

##Contact

###[Bugs](https://github.com/cray0000/type4fame/issues)
###[Email](mailto:cray0000@gmail.com)

## Code Overview

###Technologies and languages used:
 * [Derby.js](http://derbyjs.com) on Node.js
 * [Coffeescript](http://coffeescript.org/)
 * [SASS](http://sass-lang.com)/[Compass](http://compass-style.org) for stylesheets
 * [HAML](http://haml-lang.com) templates for views
 * [MongoDB](http://www.mongodb.org/)

### Code structure
```
/
  src/
    app/          # Client-Server code
    server/       # Server-only code
  haml/           # Views (compile to views/)
  sass/           # Stylesheets (compile to public/css/)
  public/         # Public folder with images, css, vendor js
```

## How to run locally

1. Clone project
``` bash
  $ git clone https://github.com/cray0000/type4fame.git
```

2. Install dependencies
``` bash
  $ cd type4fame && npm install
```

3. Install [MongoDB](http://docs.mongodb.org/manual/installation/)

4. Populate test data for mongo (need to be done only once on fresh project)
``` bash
  $ INIT_DATA=yes node server.js
```

5. Run normally
``` bash
  $ node server
```

## How to modify and contribute
You can find:
 * Views (written in HAML) in `haml/` directory.
 * Stylesheets (written in SASS) in `sass/`
 * Project code (written in Coffeescript) in `app/`

You don't need to compile `.coffee` to `.js`, because it's done automatically for you.
But `.html.haml` and `.sass` files need to be compiled into `.html` and `.css`.
To do so you'll first need to install `ruby` and ruby gems listed in `Gemfile`:
``` bash
  $ curl -L https://get.rvm.io | bash -s stable --ruby
  $ cd /path/to/type4fame
  $ bundle install
```
Now you can run
``` bash
  $ guard
```
and your `.html.haml` and `.sass` will automatically compile on every file modification.

##License
Code is licensed under GNU GPL v3. Content is licensed under CC-BY-SA 3.0.
See the LICENSE file for details.
