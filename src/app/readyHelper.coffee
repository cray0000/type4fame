_ = require('lodash')

module.exports = (model) ->

  syncTime: (updateFlag = true) ->
    sendTime = new Date
    $.getJSON '/time', (serverTime) =>
      responceTime = new Date
      diff = +responceTime - serverTime - (+responceTime - sendTime) / 2
      model.set '_timeDiff', diff
      $.cookie 'timeDiff', diff,
        expires: 30
        path: '/'
      console.log "Time sync'ed. Diff: " + diff
      if updateFlag
        $.cookie 'updatedTimeDiff', true,
          expires: 1
          path: '/'

  # Set time diff from cookie if present.
  # Else: get it "rapidly" without delay.
  # Update it everyday or after "rapid" acquiring
  # with higher 10 sec delay for better accuracy.
  initTimeDiff: ->
    if $.cookie('timeDiff')?
      model.set '_timeDiff', parseInt($.cookie('timeDiff'))
      console.log 'Time sync set from cookie.'
    else
      setTimeout @syncTime(false), 0
    if not $.cookie('updatedTimeDiff')?
      setTimeout @syncTime, 10000

  localTime: (serverTime) ->
    diff = model.get('_timeDiff')
    if diff? then (serverTime + diff)

  serverTime: (localTime) ->
    diff = model.get('_timeDiff')
    if diff? then (localTime - diff)

  # TODO Deprecated. Remove.
  clearProgress: (seed) ->
    for key, value of seed
      model.set "_player.#{key}"
      , (if _.isObject(value) then _.cloneDeep(value) else value)
    $('#input').val('')

  recoverProgress: ->
    remain = model.get('_player.typed')
    unless model.get('_player.finish')
      text = model.get('_game.text')
      remain-- until remain == 0 or (text.charAt(remain - 1) is ' ')
    model.set '_player._remain', remain
    model.set '_player.error', false

  charsFit: (text) ->
    $target = $('#target-width')
    $test = $('#test-width')
    $test.html('')
    $test.css
      'font': $target.css 'font'
      'padding': $target.css 'padding'
      'margin': $target.css 'margin'
      'border': $target.css 'border'
    count = 0
    fits = 0
    (->
      count++
      $test.html text.slice(0, count)
      fits = count if (text.charAt(count-1) == ' ' or count >= text.length)
    )() until ($test.width() > ($target.width() - 8) or count >= text.length)
    fits

  setNextLine: ->
    text = model.get('_game.text')
    begin = model.get('_player._remain')
    fits = @charsFit(text.slice(begin))
    end = begin + fits
    line = text.slice(begin, end)
    model.set '_player._line', line
    model.set '_player._current', 0
    model.set '_player._remain', end
    line

  updateStats: ->
    kAverageRuns = 30
    stats = model.at("_user.stats.langs.#{model.get '_game.langId'}.dicts.#{model.get '_game.dictId'}")
    speed = Math.floor( model.get('_game.total') / (model.get('_player.time') / 60000))
    if speed > (stats.get('record') || 0)
      stats.set('record', speed)
      model.set('_player.record', true)
    average = stats.get('average')
    lastRuns = stats.get('lastRuns') || []
    if lastRuns.length >= kAverageRuns
      stats.shift 'lastRuns'
      lastRuns.shift()
    sum = (if lastRuns.length then (lastRuns.reduce (t, s) -> t + s) else 0)
    sum += speed
    stats.set 'average', Math.round(sum / (lastRuns.length + 1))
    stats.push 'lastRuns', speed


