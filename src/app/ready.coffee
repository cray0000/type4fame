app = require '../app'
config = require './config'
{ view, ready } = require './index'
schema = require './schema'

_ = require('lodash')

#############
## Ready
#############

ready (model) ->
  user = model.at '_user'
  game = model.at '_game'
  player = model.at '_player'
  helper = (require './readyHelper')(model)
  helper.initTimeDiff()

  @on 'render:game', ->
    console.log '> RENDER'

    clearTimeout @timerId
    if game.get('start')?
      @timer()
    else
      game.set '_time', (- game.get('countdown'))

#    helper.clearProgress schema._player
    $('#input').val('').focus()
    helper.recoverProgress()
    helper.setNextLine()

  @on 'render:games', ->
    model.set '_rendered', true #Math.random()

  game.on 'set', 'start', (startTime) =>
    @timer()

  player.on 'set', 'finish', (finish) =>
    if finish
      player.set 'time', (+new Date) - helper.localTime(game.get 'start')
      clearTimeout(@timerId)
      helper.updateStats()


  player.on 'set', '_current', (current) ->
    line = player.get '_line'
    player.set '_view.line', {
      prev: line.slice(0, current)
      next: line.slice(current, current + 1)
      rest: line.slice(current + 1)
    } if line?
  player.on 'set', '_remain', (remain) =>
    player.set '_view.fromSecondLine', (game.get 'text').slice(remain)
  model.on 'set', '_serverTime', (time) =>
    model.set '_user.lastActive', time

  @timer = =>
    time = (+new Date) - helper.localTime(game.get 'start')
    game.set('_ready', true)
    game.set('_steady', true) if time >= -4000
    sec = Math.round(time / 1000)
    $('#input').val('') if sec == 0
    game.set('_go', true) if time >= 0
    game.set('_countdown', -sec) if sec >= -3 and sec < 0
    game.set '_time', sec
    tick = Math.abs(time % 1000)
    if time >= 0
      tick = 1000 - tick
    @timerId = setTimeout @timer, (tick + 1)

  @start = (e, input, next) ->
    start = helper.serverTime(+new Date) + game.get('countdown') * 1000
    game.setNull 'start', start
    model.setNull '_lobby.start', start
    $('#input').focus()

  @handleGameInput = (e, input, next) ->
    line = player.get '_line'
    error = (input.value != line.slice(0, input.value.length))
    if error
      player.incr 'errors' if not player.get('error')
    else
      if input.value.length >= line.length
        input.value = ''
        line = helper.setNextLine()
      else
        player.set '_current', input.value.length
      player.set 'typed', player.get('_remain') - (line.length - input.value.length)
      if not line
        player.set 'finish', true
    player.set 'error', error

  @handleChat = (e, input, next) ->
    console.log 'Chat'

  # Handle Game logic on text input
  @input = (e, input, next) ->
    if e.which == 13 and e.shiftKey
      if not game.get('_ready')
        @start()
      else
        console.log '#' + game.get('langId')
        view.app.history.push "/new/#{game.get 'langId'}"
#        $('#' + game.get('langId')).click()

    if player.get('finish') or not game.get('_go')
      @handleChat(e, input, next)
    else
      @handleGameInput(e, input, next)

  @showChars = (e, el, next) ->
    model.set '_showSelectChar', true

  @selectChar = (e, el, next) ->
    $el = $(el)
    char = $el.attr('rel')
    player.set 'char', char
    model.set '_user.char', char
    $el.addClass('selected').siblings().removeClass('selected')
    $('#chars-box').trigger('reveal:close');

  # Connect/Reconnect to server
  model.set '_showReconnect', true
  @connect = ->
    # Hide the reconnect link for a second after clicking it
    model.set '_showReconnect', false
    setTimeout (-> model.set '_showReconnect', true), 1000
    model.socket.socket.connect()

  @reload = -> window.location.reload()

