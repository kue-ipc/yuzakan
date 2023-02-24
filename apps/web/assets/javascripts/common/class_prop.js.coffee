# class in props

import {uniq, comact} from '/assets/common/helper.js'

export parseClassProp = (obj) ->
  if !obj?
    []
  else if typeof obj == 'string'
    (item for item in obj.split(/\s+/) when item)
  else if obj instanceof Array
    obj
  else if typeof obj == 'object'
    (String(key) for own key, value of obj when value)
  else
    console.warn 'Not a string, an array, or an object.'
    []

export classConcat = (objs...) ->
  compact(uniq(objs.map(parseClassProp).flat()))
