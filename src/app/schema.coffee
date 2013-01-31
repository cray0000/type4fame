# Schema data. Not used actually. It's here just to see the db structure.
# TODO: Refactor and make schema useful (for example deepClone it to create game/player/...)

module.exports =
  game:
#    text: ''
#    total: null
#    dict: ''
    langId: 'en'
    dictId: 'general'
    time: undefined
    playerIds: []
    players: {}
  player:
#    id: ''
#    name: ''
    typed: 0
    errors: 0
    error: false
    finish: false
  _player:
    _line: null
    _current: 0 # current symbol to type in first line
    _remain: 0 # first symbol of remaining text (excluding the typing line)
    # View only
    _view:
      line:
        prev: ''
        next: ''
        rest: ''
      fromSecondLine: ''
#  chars:
#    user:
#      [
#        {
#          name: "car"
#          values: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41]
#        }
#      ]
#    anonymous:
#      [
#        {
#          name: "car"
#          values: [1,2,3]
#        }
#      ]
  lang:
#    id: 'en'
    name: 'English'
    dicts:
      general:
        id: 'general'
        name: 'English'
        description: 'General English texts.'
        size: 1
  text:
#    id: model.id()
    lang: 'en'
    dict: 'general'
    key: '1'
    text: 'Hello world.'

