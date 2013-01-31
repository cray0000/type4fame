{ get } = require './index'
controller = require './controller'

## ROUTES ##

get '/', controller.games
get '/new', controller.new
get '/new/:langId?/:dictId?', controller.new
get '/games', controller.games
get '/game/:gameId?', controller.game
get '/init', controller.init