{ view } = require './index'
utils = require '../lib/utils'

# View Functions
view.fn 'error', (error) ->
  if error then 'error' else ''

view.fn 'finish', (finish) ->
  if finish then 'Finished' else 'Not finished'

view.fn 'progress', (typed, total) ->
  (80 - typed / total * 80) + '%'

view.fn 'record', (record) ->
  if record then 'record' else ''

view.fn 'result', (finish) ->
  if finish then 'result' else ''

view.fn 'showStart', (ready) ->
  if ready then 'ready' else ''

view.fn 'time', (time) ->
  if time?
    if time < 0
      tmp = -time
      sign = '-'
    else
      tmp = time
      sign = ''
    sec = tmp % 60
    "#{sign}#{Math.floor(tmp / 60)}:#{if sec < 10 then '0' else ''}#{sec}"

view.fn 'speed', (time, total) ->
  if time?
    Math.floor(total / (time / 60000))
  else
    '-'

view.fn 'errorsMark', (errors, total) ->
  switch
    when errors <= 1 then 'excellent'
    when errors > 1 and errors <= total * 0.02 then 'good'
    when errors > total * 0.02 and errors <= total * 0.05 then 'normal'
    else 'bad'

view.fn 'showTime', (go, finish) ->
  if not go or finish then '' else 'hidden'

view.fn 'showGate', (steady) ->
  if steady then 'off-gate' else ''

view.fn 'showCountdown', (go) ->
  if go then 'off-countdown' else ''

view.fn 'gateMessage', (ready) ->
  if ready then 'Game started' else 'Waiting for players'

# Spagetti function. Sets _cd.#{gameId} to the model so that different
# games starts could be counted down independantly
view.fn 'statusText', (start, diff, countdown, gameId) ->
  if start? and diff?
    time = start + diff
    remain = time - (+new Date)
    if remain < 0
      if not countdown?
        view.model.set "_cd.#{gameId}", -1
      "in process"
    else
      sec = Math.round(remain / 1000)
      setTimeout ->
        view.model.set "_cd.#{gameId}", sec - 1
      , remain % 1000 + 1
      "#{Math.floor(sec / 60)}:#{if sec % 60 < 10 then '0' else ''}#{sec % 60}"
  else
    "waiting"

# This function exploits _cd.#{gameId} set by previous funciton
view.fn 'status', (start, countdown) ->
  if not countdown?
    "waiting"
  else if countdown > 0
    "ready"
  else
    "go"

