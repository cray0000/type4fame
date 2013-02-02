derby = require 'derby'
schema = require './schema'
helper = require './modelHelper'

_ = require('lodash')

controller =
  index: (page, model) ->
    page.render 'index'

  game: (page, model, {gameId}) ->
    return (page.redirect '/games') if not gameId?

    userId = model.session?.userId || (model.get '_userId')
    model.setNull '_userId', userId

    model.subscribe "games.#{gameId}"
    , "lobbies.#{gameId}"
    , "users.#{userId}"
    , "config.general"
    , "lobbies"
    , (err, game, lobby, user, config, lobbies) ->

      return (page.redirect '/games') if not game.get('id')?
#      console.log "Error: " + err

      model.ref '_user', user
      model.ref '_game', game
      model.ref '_config', config
      model.ref '_lobby', lobby
      model.ref '_lobbies', lobbies
      model.fn '_gamesId', '_lobbies', (lobbies) ->
        (key for key, value of lobbies).reverse()
      model.refList '_games', lobbies, '_gamesId'
      model.ref '_player', "_game.players.#{userId}"
      model.refList '_players', '_game.players', '_game.playerIds'

      hasPlayer = game.get("players.#{userId}.id")?
      userObj = model.get('_user')
      userObj.char ?= 'car-4'
      userObj.gameId = gameId

      # FIXME: Couses 1000ms bug being placed after adding to _game.players
      unless hasPlayer
        model.push "_lobby.players",
          id: userId
          name: userObj.auth?.local?.username || 'Batman'
          char: userObj.char

      userObj = model.get('_user')
      userObj.char ?= 'car-4'
      userObj.gameId = gameId
      if derby.util.isServer
        userObj.lastActive = +new Date
      model.set "users.#{userId}", userObj

      unless hasPlayer
        model.setNull "_game.players.#{userId}",
          id: userId
          name: userObj.auth?.local?.username || 'Batman'
          char: userObj.char
          typed: 0
          errors: 0
          error: false
          finish: false
        model.push '_game.playerIds', userId

      page.render 'game'

  new: (page, model, {langId, dictId}) ->
    gameId = model.id()
    langId ?= 'en'
    dictId ?= 'general'
    model.subscribe "langs.#{langId}", (err, lang) ->
      randomText = model.query('texts').getRandomText
        key: '' + _.random(1, lang.get "dicts.#{dictId}.size")
        lang: langId
        dict: dictId
      model.subscribe randomText, (err, result) ->
        textObj = result.at(result.get().length - 1)
        model.subscribe "games.#{gameId}"
        , "lobbies.#{gameId}"
        , "config.general"
        , (err, game, lobbie, config) ->
          text = textObj.get 'text'
          game.set
            text: text
            total: text.length
            start: null
            countdown: 6
            langId: langId
            dictId: dictId
            playerIds: []
            players: {}
          lobbie.set
            players: []
            start: null
            lang: lang.get 'name'
            dictId: lang.get "dicts.#{dictId}.name"
          config.unshift 'lobbies', gameId
          page.redirect "/game/#{gameId}"
#          page.render "index"

  games: (page, model) ->
    userId = model.session?.userId || (model.get '_userId')
    model.setNull '_userId', userId

    model.subscribe "config.general"
    , "users.#{userId}"
    , "lobbies"
    , (err, config, user, lobbies) ->
      model.ref '_config', config
      model.ref '_user', user
      model.ref '_lobbies', lobbies
      # Usage of refList instead of direct array reactive function is better
      # here because .reverse() is less expensive on array of id's then
      # on a whole objects
      model.fn '_gamesId', '_lobbies', (lobbies) ->
        (key for key, value of lobbies).reverse()
      model.refList '_games', lobbies, '_gamesId'
      page.render 'games'


  init: (page, model) ->
    page.render 'index'




module.exports = controller

# import ready callback
require './ready'

# import view functions
require './viewFunctions'
