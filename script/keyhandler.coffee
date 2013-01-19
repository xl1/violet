class KeyHandler
  @KEYDOWN_STRING =
    8: 'BS'
    9: 'Tab'
    13: 'Enter'
    27: 'Esc'
    28: 'Henkan'
    29: 'Muhenkan'
    32: 'Space'
    33: 'PageUp'
    34: 'PageDown'
    35: 'End'
    36: 'Home'
    37: 'Left'
    38: 'Up'
    39: 'Right'
    40: 'Down'
    44: 'PrintScreen'
    45: 'Ins'
    46: 'Del'
    112: 'F1'
    113: 'F2'
    114: 'F3'
    115: 'F4'
    116: 'F5'
    117: 'F6'
    118: 'F7'
    119: 'F8'
    120: 'F9'
    121: 'F10'
    122: 'F11'
    123: 'F12'
    
  @KEYPRESS_STRING =
    10: 'Enter' #<C-Enter>
    13: 'Enter'
    32: 'Space'
  
  @splitKeySeq: (keySeq) ->
    res = []
    for frag in keySeq.split(/(?=<)|>/)
      if frag[0] is '<'
        res.push frag + '>'
      else
        res = res.concat frag.split('')
    res
     
  constructor: ->
    @_stack = []
    @_timerID = null
    @_keyMap = []
    @_functions = {}
    
    @last = ''
    
    # settings
    @INTERVAL = 800#ms
    
    stage.on 'keydown', (e) =>
      code = e.which or e.keyCode
      return if 16 <= code <= 18 # Ctrl Shift Alt
      key = KeyHandler.KEYDOWN_STRING[code] or
            String.fromCharCode(code % 144).toLowerCase()
        
      key = (if e.ctrlKey then 'C-' else '') +
        (if e.shiftKey then 'S-' else '') +
        (if e.altKey then 'M-' else '') +
        key
      @last = if key.length is 1 then key else "<#{key}>"
      setTimeout (=> @_handle @last), 0
    
    stage.on 'key', (e) =>
      code = e.which or e.keyCode
      unless key = KeyHandler.KEYPRESS_STRING[code]
        if code <= 26 # from 1..26
          code += 96  #   to a..z
        key = String.fromCharCode(code)
      
      key = (if e.ctrlKey then 'C-' else '') +
        (if e.altKey then 'M-' else '') +
        key
      @last = if key.length is 1 then key else "<#{key}>"
    
  on: (keySeq, func) ->
    if arguments.length is 1
      @on ks, f for own ks, f of keySeq
      return
    @_keyMap.push keySeq
    @_functions[keySeq] = func
      
  getCanditates: (keySeq) ->
    keySeq or= @_stack.join ''
    @_keyMap.filter (keys) -> 
      keys.indexOf(keySeq) is 0
    
  getFunc: (keySeq) ->
    keySeq or= @_stack.join ''
    @_functions[keySeq]
    
  _handle: (keyString) ->
    if @_timerID?
      clearTimeout @_timerID
      @_timerID = null
      
    @_stack.push keyString
    until count = @getCanditates().length
      @_stack.pop()
      if @_stack.length
        @getFunc()?()
        @_stack.splice(0, Infinity, keyString)
      
    if f = @getFunc()
      if count is 1
        f()
        @_stack.splice 0
      else
        @_timerID = setTimeout =>
          f()
          @_stack.splice 0
        , @INTERVAL
        
  sendKeys: (keySeq) ->
    KeyHandler.splitKeySeq(keySeq).forEach @_handle.bind(@)