#lazy = require("lazy")
#fs = require("fs")
#
#(->
#  ruSize = 0
#  enSize = 0
#  total = 0
#  timeout = 50
#  new lazy(fs.createReadStream(path.join publicPath, 'text.csv')).lines.forEach (line) ->
#    setTimeout ->
#      line = line.toString().split('#')
#      index = line[0]
#      text = line[1]
#      if index < 9091 then ruSize++ else enSize++
#      total++
#      store.set "texts.#{total}",
#        lang: if index < 9091 then 'ru' else 'en'
#        dict: 'general'
#        key: "#{if index < 9091 then ruSize else enSize}"
#        text: text
#      console.log "#{total} ##{index} - #{if index < 9091 then 'ru' else 'en'}"
#      if total == 4836
#        store.set "langs.en.dicts.general.size", enSize
#        console.log "English total: " + enSize
#        store.set "langs.ru.dicts.general.size", ruSize
#        console.log "Russian total: " + ruSize
#    , (timeout += 25)
#)()
