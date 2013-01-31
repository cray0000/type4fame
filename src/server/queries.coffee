store = require('./index').pvStore

_ = require('lodash')

store.accessControl = true

# TODO: Add normal Access control.
# FIXME: Access control! Very Important!

store.readPathAccess 'collection.*', () -> #captures, next) ->
  next = arguments[arguments.length - 1]
  next(true)

store.readPathAccess 'games', () -> #captures, next) ->
  next = arguments[arguments.length - 1]
  next(true)

store.writeAccess '*', 'games', () ->
  arguments[arguments.length - 1](true)

store.readPathAccess 'games.*', () -> #captures, next) ->
  next = arguments[arguments.length - 1]
  next(true)

store.writeAccess '*', 'games.*', () ->
  arguments[arguments.length - 1](true)


store.readPathAccess 'config.*', () -> #captures, next) ->
  next = arguments[arguments.length - 1]
  next(true)

store.writeAccess '*', 'config.*', () ->
  arguments[arguments.length - 1](true)

store.readPathAccess 'lobbies', () -> #captures, next) ->
  next = arguments[arguments.length - 1]
  next(true)

store.writeAccess '*', 'lobbies', () ->
  arguments[arguments.length - 1](true)

store.readPathAccess 'lobbies.*', () -> #captures, next) ->
  next = arguments[arguments.length - 1]
  next(true)

store.writeAccess '*', 'lobbies.*', () ->
  arguments[arguments.length - 1](true)

store.readPathAccess 'users', () -> #captures, next) ->
  next = arguments[arguments.length - 1]
  next(true)

store.writeAccess '*', 'users', () ->
  arguments[arguments.length - 1](true)





store.writeAccess '*', 'langs', () ->
  arguments[arguments.length - 1](true)

store.writeAccess '*', 'texts', () ->
  arguments[arguments.length - 1](true)

store.readPathAccess 'langs', () -> #captures, next) ->
  next = arguments[arguments.length - 1]
  next(true)

store.readPathAccess 'texts', () -> #captures, next) ->
  next = arguments[arguments.length - 1]
  next(true)

store.writeAccess '*', 'langs.*', () ->
  arguments[arguments.length - 1](true)

store.writeAccess '*', 'texts.*', () ->
  arguments[arguments.length - 1](true)

store.readPathAccess 'langs.*', () -> #captures, next) ->
  next = arguments[arguments.length - 1]
  next(true)

store.readPathAccess 'texts.*', () -> #captures, next) ->
  next = arguments[arguments.length - 1]
  next(true)


## Query Motifs

store.query.expose 'users', 'hasId', (id) ->
  @where('id').equals(id)

store.query.expose 'lobbies', 'active', (activeLobbies) ->
  @where('id').in(activeLobbies)

store.query.expose 'collection', 'getYear', (year) ->
  @where('year').equals year

store.query.expose 'texts', 'getRandomText', (obj) ->
  @where('key').equals(obj.key).where('lang').equals(obj.lang).where('dict').equals(obj.dict)

store.query.expose 'texts', 'getAmount', (langId) ->
  @where('lang').equals('langId')

store.query.expose 'lobbies', 'getOld', (time) ->
  @where('start').lt(time - 60000)

## Give query access

giveQueryAccess = (col, fn) ->
  store.queryAccess col, fn, (methodArgs) ->
    accept = arguments[arguments.length - 1]
    accept true # for now

obj =
  collection: ['getYear']
  texts: ['getRandomText', 'getAmount']
  lobbies: ['getOld']

for col of obj
  obj[col].map (fn) -> giveQueryAccess col, fn
