# class in props

export convertArray = (obj) ->
  if !obj?
    []
  else if typeof obj == 'string'
    (item for itme in obj.split(/\s+/) when item)
  else if obj instanceof Array
    obj
  else if typeof obj[Symbol.iterator] == 'function'
    [obj...]
  else if typeof obj == 'object'
    (key for own key, value of obj when value)
  else
    console.warn 'Not a string, an array, or an object.'

export convertString = (obj) ->
  if !obj?
    ''
  else if typeof obj == 'string'
    obj
  else if obj instanceof Array
    obj.join(' ')
  else if typeof obj[Symbol.iterator] == 'function'
    [obj...].join(' ')
  else if typeof obj == 'object'
    (key for own key, value of obj when value).join(' ')
  else
    console.warn 'Not a string, an array, or an object.'

export join = (objs...) ->
  [new Set(objs.map(convertArray).flat())...]

export default classProp = {
  convertArray
  convertString
  join
}
