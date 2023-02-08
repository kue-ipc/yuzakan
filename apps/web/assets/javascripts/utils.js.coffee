# utils

import * as R from '/assets/vendor/ramda.js'

export isNil = R.isNil

export isEmpty = R.isEmpty

export isBlank = (obj) -> isNil(obj) || isEmpty(obj)

export isPresent = R.compose(R.not, isBlank)

export presence = (obj) ->
  if isPresent(obj)
    obj
  else
    null

export compact = (obj) ->
  switch R.type(obj)
    when 'Array'
      (v for v in obj when v?)
    when 'Object'
      Object.fromEntries([k, v] for own k, v of obj when v?)
    when 'Map'
      new Map([k, v] for [k, v] from obj when v?)
    when 'Set'
      new Set(v for v from obj when v?)
    else
      console.warn "cannot compact type: #{R.type(obj)}"
      obj

export pick = R.flip(R.pick)

export pickType = (obj, keys) ->
  Object.fromEntries([key, convertToType(obj[key], type)] for own key, type of keys when obj.hasOwnProperty(key))

TRUE_STRINGS = [
  '1'
  't'
  'true'
  'y'
  'yes'
  'on'
]

FALSE_STRINGS = [
  '0'
  'f'
  'false'
  'n'
  'no'
  'off'
]

# convert to the specified type
export convertToType = (val, type = 'string') ->
  return val if typeof val == type

  unless val?
    if type == 'object' || type == 'function'
      return null
    else
      return undefined

  switch type
    when 'undefiend'
      undefined
    when 'object'
      Object(val)
    when 'boolean'
      if typeof val == 'string'
        lowerStr = val.toLowerCase()
        if TRUE_STRINGS.includes(lowerStr)
          true
        else if FALSE_STRINGS.include(lowerStr)
          false
        else
          console.warn "no boolean string: #{val}"
          Boolean(val)
      else
        Boolean(val)
    when 'number'
      Number(val)
    when 'bigint'
      BigInt(val)
    when 'string'
      String(val)
    when 'symbol'
      Symbol(val)
    when 'function'
      Funicton(val)
    else
      console.warn "cannot convert to the unknown type: #{type}"
      undefined


# TODO
# export deepFreeze = (obj)
#   return obj if Object.isFrozen(obj)

#   Object.freeze(obj)
#   switch Object.getPrototypeOf(obj).constructor
#     when Object
#       deepFreeze(value) for own key, value of obj
#     when Array
#       deepFreeze(value) for value in obj
#     when Map
#       deepFreeze(value) for value from obj.values()
#     when Set
#       deepFreeze(value) for value from obj
#   obj

# export clone

# export deepClone

