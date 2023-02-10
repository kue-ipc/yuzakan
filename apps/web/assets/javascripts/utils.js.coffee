# utils

import * as R from '/assets/vendor/ramda.js'
import {DateTime} from '/assets/vendor/luxon.js'

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

export objToJson = (obj) ->
  JSON.stringify obj, (key, value) ->
    # TODO
    return String(value) if typeof value == 'bigint'
    return value if typeof value != 'object'

    if value instanceof Map
      Object.fromEntries([value...])
    else if value instanceof Set
      [value...]
    else
      obj

TYPES = [
  'array'
  'decimal'
  'array'
  'decimal'
  'bool'
  'date'
  'date_time'
  'float'
  'hash'
  'int'
  'str'
  'time'
]

# convert to the specified type
export convertToType = (val, type = 'string') ->
  return val unless val?

  switch type
    when 'string', 'text'
      String(val)
    when 'boolean'
      if typeof val == 'string'
        lowerStr = val.toLowerCase()
        if TRUE_STRINGS.includes(lowerStr)
          true
        else if FALSE_STRINGS.includes(lowerStr)
          false
        else
          console.warn "no boolean string: #{val}"
          Boolean(val)
      else
        Boolean(val)
    when 'integer'
      Math.floor(Number(val))
    when 'float'
      Number(val)
    when 'datetime'
      switch typeof val
        when 'number'
          DateTime.fromSeconds(val)
        when 'bigint'
          DateTime.fromSeconds(Number(val))
        when 'string'
          DateTime.fromISO(val)
        when 'object'
          if val instanceof Date
            DateTime.fromJSDate(val)
          else if val instanceof DateTime
            val
          else
            console.warn "no datetime object: #{val}"
            DateTime.fromJSDate(Date(val))
        else
          console.warn "no datetime object: #{val}"
          DateTime.fromJSDate(Date(val))
    when 'date'
      convertToType(val, 'datetime').toISODate()
    when 'time'
      convertToType(val, 'datetime').toISOTime(includeOffset: false)
    when 'list'
      value
    when 'map'
      value
    when 'set'
      vaule
    else
      console.warn "cannot convert to the unknown type: #{type}"
      undefined

export toInteger = (val) ->
  # not use bigint
  val ? Math.floor(Number(val))



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

