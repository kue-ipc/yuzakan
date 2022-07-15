# 入力イベントの値を渡すアクションを生成する

export createEventValueAction = (action, {type = 'string'} = {}) ->
  switch type
    when 'string', 'text', 'datetime', 'date', 'time'
      (state, event) -> [action, event.target.value]
    when 'boolean'
      (state, event) ->
        if event.type == 'checkbox'
          [action, Number(event.target.checked)]
        else if event.target.value && !['n', 'no', 'f', 'false', 'off', '0'].includes(event.target.value.toLowerCase())
          [action, true]
        else
          [action, false]
    when 'integer'
      (state, event) -> [action, parseInt(event.target.value, 10)]
    when 'float'
      (state, event) -> [action, Number(event.target.value)]
    else
      throw new Error("unknown type: #{type}")
