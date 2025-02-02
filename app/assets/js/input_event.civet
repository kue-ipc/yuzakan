# 入力イベントの値を渡すアクションを生成する

export createEventValueAction = (action, {type = 'string'} = {}) ->
  switch type
    when 'string', 'text', 'datetime', 'date', 'time'
      (state, event) ->
        event.preventDefault()
        [action, event.target.value]
    when 'boolean'
      (state, event) ->
        event.preventDefault()
        if event.type == 'checkbox'
          [action, Number(event.target.checked)]
        else if event.target.value && !['n', 'no', 'f', 'false', 'off', '0'].includes(event.target.value.toLowerCase())
          [action, true]
        else
          [action, false]
    when 'integer'
      (state, event) ->
        event.preventDefault()
        [action, parseInt(event.target.value, 10)]
    when 'float'
      (state, event) ->
        event.preventDefault()
        [action, Number(event.target.value)]
    else
      throw new Error("unknown type: #{type}")

export createEventAction = (action, opts = {}) ->
  event.preventDefault()
  [action, opts]
