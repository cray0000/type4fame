{ expressApp } = require './index'
## Routes

controller = require './controller'

expressApp.get '/status', controller.status
expressApp.get '/time', controller.time
#expressApp.get '/init', controller.init
expressApp.all '*', controller.all
