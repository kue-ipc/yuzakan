# list helper

export updateList = (list, id, data, {key = 'id'}) ->
  for item in list
    if item[key] == id
      {item..., data...}
    else
      item

export findList = (list, id, {key = 'id'}) ->
  for item in list
    if item[key] == id
      return item
  
  null

export deleteList = (list, id, {key = 'id'}) ->
  item for item in list when item[key] != id

export createList = (list, data, {key = 'id'}) ->
  list.concat(data)
