expressApp = require('./index').expressApp
config = require './config'

## SERVER ONLY ROUTES ##

module.exports.status = (req, res) ->
  obj =
    status: 'up'
    easteregg: false
  if req.query.easteregg
    obj.easteregg = true
    obj.hello = 'World'
  res.json obj

module.exports.time = (req, res) ->
  res.json +new Date

module.exports.all = (req, res) ->
  res.send 404, '404 Page not found'

#module.exports.init = (req, res) ->
#  model = req.getModel()
#  model.subscribe "langs", "texts", (err, langs, texts) ->
#    console.log err
#    model.set 'langs',
#      en:
#        id: 'en'
#        name: 'English'
#        dicts:
#          general:
#            id: 'general'
#            name: 'English'
#            description: 'General English texts.'
#            size: 2
#      ru:
#        id: 'ru'
#        name: 'Russian'
#        dicts:
#          general:
#            id: 'general'
#            name: 'Русский'
#            description: 'Основной набор текстов.'
#            size: 2
#    model.set 'texts',
#      1:
#        id: '1'
#        lang: 'ru'
#        dict: 'general'
#        key: '1'
#        text: 'Привет мир.'
#      2:
#        id: '2'
#        lang: 'ru'
#        dict: 'general'
#        key: '2'
#        text: 'Привет опять.'
#      3:
#        id: '3'
#        lang: 'en'
#        dict: 'general'
#        key: '1'
#        text: 'Hello world.'
#      4:
#        id: '4'
#        lang: 'en'
#        dict: 'general'
#        key: '2'
#        text: 'Hello again.'
#    res.json
#      langs: model.get('langs')
#      texts: model.get('texts')

