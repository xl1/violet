class Point extends Model
  constructor: (@x, @y) ->
    super()

  move: (dx, dy) ->
    @x += dx
    @y += dy
    @change()

  moveTo: (@x, @y) -> @change()


class Grid extends Model
  constructor: (@width, @height, @size=64) ->
    super()

  dense:  (rank=1) -> @size >>= rank; @change()
  sparse: (rank=1) -> @size <<= rank; @change()


class Cursor extends Model
  constructor: ->
    super()
    { width, height } = stage
    @cursor = new Point(width >> 1, height >> 1)
    @grid = new Grid(width, height)
    @adjust()

  move: (dx, dy) ->
    size = @grid.size
    @cursor.move(dx * size, dy * size)

  adjust: ->
    size = @grid.size
    x = (@cursor.x / size |0) * size
    y = (@cursor.y / size |0) * size
    @cursor.moveTo(x, y)

  dense: (rank=1) -> @grid.dense(rank); @adjust()
  sparse: (rank=1) -> @grid.sparse(rank); @adjust()


class CursorView extends View
  watch: (model) ->
    super model
    @shape = new Circle(0, 0, 2).addTo(stage).attr {
      strokeWidth: 1
      strokeColor: 'red'
    }
    @render()

  render: ->
    @shape.attr { x: @model.x, y: @model.y }


class Selector extends Model
  select: (@selection) -> @change()
  unselect: -> @select null

  addPoint: (cursor) ->
    { x, y } = cursor.cursor
    @selection?.lineTo(x, y) or
      (@selection = new Path([x, y]).stroke('black', 1).addTo(stage))
    @change()

  fill: ->
    @selection?.fill('black')

  cut: ->
    @selection?.destroy()
    @select null

  close: ->
    @selection?.closePath()
    @change()


class SelectorView extends View
  watch: (model) ->
    super model
    @shape = new Rect(0, 0, 0, 0).attr {
      fillColor: 'rgba(60, 200, 100, 0.1)'
    }

  render: ->
    if target = @model.selection
      { left, top, width, height } = target.getBoundingBox()
      @shape.attr({ x: left, y: top, width, height }).addTo(stage)
    else
      @shape.remove()


class GridView extends View
  watch: (model) ->
    super model
    @render()

  render: ->
    { width, height, size } = @model
    @shape?.remove()
    shape = new Path().attr {
      strokeWidth: 1
      strokeColor: '#ddd'
    }
    for x in [0..width] by size
      shape.moveTo(x, 0).lineTo(x, height)
    for y in [0..height] by size
      shape.moveTo(0, y).lineTo(width, y)
    @shape = shape.addTo(stage)


main = ->
  cursor = new Cursor
  new GridView(cursor.grid)
  new CursorView(cursor.cursor)

  selector = new Selector
  new SelectorView(selector)
  
  key = new KeyHandler
  key.on {
    'h': -> cursor.move(-1,  0)
    'j': -> cursor.move( 0,  1)
    'k': -> cursor.move( 0, -1)
    'l': -> cursor.move( 1,  0)
    '+': -> cursor.sparse()
    '-': -> cursor.dense()
    '<Space>': -> selector.addPoint(cursor)
    'z': -> selector.close()
    'f': -> selector.fill()
    'd': -> selector.cut()
    '<Esc>': -> selector.unselect()
  }

main()