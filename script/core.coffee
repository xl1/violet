uuid = do ->
  re = /[xy]/g
  replacer = (c) ->
    r = Math.random() * 16 |0
    (if c is 'x' then r else (r & 3 | 8)).toString 16
  ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(re, replacer).toUpperCase()


class Model
  constructor: ->
    @id = uuid()

  change: ->
    stage.emit 'change:' + @id


class View
  constructor: (model) ->
    @watch model if model
  
  watch: (model) =>
    if @model
      stage.removeListener 'change:' + @model.id
    @model = model
    stage.on 'change:' + model.id, @render.bind(@)
