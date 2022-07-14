# 入力イベントの値を渡すアクションを生成する

export createEventValueAction = (action, {type = 'string'} = {}) ->
  switch type
    when 'string'
      (state, event) -> [action, event.target.value]
    when 'integer'
      (state, event) -> [action, parseInt(event.target.value, 10)]
    when 'float'
      (state, event) -> [action, Number(event.target.value)]
    else
      throw new Error("unknown type: #{type}")
