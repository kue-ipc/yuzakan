

export class_to_arr = (obj) ->
  if !obj?
    []
  else if typeof obj == 'string'
    obj.split(' ')



