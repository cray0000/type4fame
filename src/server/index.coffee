http = require 'http'
path = require 'path'
express = require 'express'
derby = require 'derby'


racer = require 'racer'
racer.set('bundleTimeout', 40000)

auth = require 'derby-auth'
app = require '../app'
serverError = require './serverError'
io = racer.io

## SERVER CONFIGURATION ##

expressApp = express()
server = module.exports = http.createServer expressApp
module.exports.expressApp = expressApp

derby.use require('racer-db-mongo')

store = module.exports.pvStore = derby.createStore
  listen: server
  db:
    type: 'Mongo'
    uri: 'mongodb://localhost/type4fame'
    safe: true

ONE_YEAR = 1000 * 60 * 60 * 24 * 365
root = path.dirname path.dirname __dirname
publicPath = path.join root, 'public'

# Authentication setup.
if process.env.NODE_ENV is "production"
  strategies =
    facebook:
      strategy: require("passport-facebook").Strategy
      conf:
        clientID: process.env.FACEBOOK_KEY
        clientSecret: process.env.FACEBOOK_SECRET
else
  strategies = {}

options =
  domain: process.env.BASE_URL || 'http://localhost:3000'

expressApp
  .use(express.favicon())
  # Gzip static files and serve from memory
  .use(express.static publicPath)
  # Gzip dynamically rendered content
  .use(express.compress())

  # Uncomment to add form data parsing support
  .use(express.bodyParser())
  .use(express.methodOverride())

  # Uncomment and supply secret to add Derby session handling
  # Derby session middleware creates req.session and socket.io sessions
  .use(express.cookieParser())
  .use(store.sessionMiddleware
    secret: process.env.SESSION_SECRET || 'session secret'
    cookie: {maxAge: ONE_YEAR}
  )

  # Adds req.getModel method
  .use(store.modelMiddleware())

  # Type4Fame Custom Middleware
  .use (req, res, next) ->
    model = req.getModel()
    model.set '_serverTime', +new Date
    next()

  # Adds auth
  .use(auth(store, strategies, options))
  # Creates an express middleware from the app's routes
  .use(app.router())
  .use(expressApp.router)
  .use(serverError root)


setInterval ->
  store.set 'config.general.serverTime', +new Date
, 10 * 1000

routes = require './routes'

queries = require './queries'


# TODO Get rid of this awful if statement. Create separate file for initial data
if process.env.INIT_DATA is "yes"
  (->
    model = store.createModel()
    model.set "langs.en.name", 'English'
    model.set "langs.en.description", 'General texts in English.'
    model.set "langs.ru.name", 'Russian'
    model.set "langs.ru.description", 'General texts in Russian.'

    lazy = require("lazy")
    fs = require("fs")

    ruSize = 0
    enSize = 0
    total = 0
    timeout = 50
    new lazy(fs.createReadStream(path.join publicPath, 'text.csv')).lines.forEach (line) ->
      setTimeout ->
        line = line.toString().split('#')
        index = line[0]
        text = line[1]
        if index < 9091 then ruSize++ else enSize++
        total++
        store.set "texts.#{total}",
          lang: if index < 9091 then 'ru' else 'en'
          dict: 'general'
          key: "#{if index < 9091 then ruSize else enSize}"
          text: text
        console.log "#{total} ##{index} - #{if index < 9091 then 'ru' else 'en'}"
        if total == 4836
          store.set "langs.en.dicts.general.size", enSize
          console.log "English total: " + enSize
          store.set "langs.ru.dicts.general.size", ruSize
          console.log "Russian total: " + ruSize
      , (timeout += 25)
  )()


# Delete all lobbies on server start
(->
  model = store.createModel()
  model.fetch "lobbies", (err, lobbies) ->
    model.del("lobbies.#{id}") for id, lobby of lobbies.get()
)()

# Server cron task. Delete started games after certain amount of time
# (see queries.coffee)
setInterval ->
  model = store.createModel()
  q = model.query('lobbies').getOld(+new Date)
  model.fetch q, (err, lobbies) ->
    model.del("lobbies.#{lobby.id}") for lobby in lobbies.get()
, 10 * 1000

# Infinite stack trace
Error.stackTraceLimit = Infinity

io.configure 'production', ->
  io.set "transports", ["websocket", "xhr-polling", "jsonp-polling", "htmlfile"]

if process.env.NODE_ENV is "production"
  # If error is thrown, don't crash the server
  process.on 'uncaughtException', (err) ->
    console.log err.stack
    console.log "Node NOT Exiting..."
else
  racer.use(racer.logPlugin)
  derby.use(derby.logPlugin)
