# form helper

export fieldName = (name, parents = []) ->
  list = [parents..., name]
  str = list[0]
  str += "[#{key}]" for key in list[1..]
  str


export fieldId = (name, parents = []) ->
  [parents..., name]
    .map (key) -> key.replace(/_/g, '-')
    .join('-')
