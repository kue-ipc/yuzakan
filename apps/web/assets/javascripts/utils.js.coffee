# utils

import * as R from '/assets/vendor/ramda.js'
import {DateTime} from '/assets/vendor/luxon.js'

export isNil = R.isNil

export isEmpty = R.isEmpty

export isBlank = (obj) -> isNil(obj) || isEmpty(obj)

export isPresent = R.compose(R.not, isBlank)

export identity = R.identity

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
  Object.fromEntries([key, convertToType(obj[key], type)] for own key, type of keys when key of obj)

TRUE_STRINGS = new Set([
  '1'
  't'
  'true'
  'y'
  'yes'
  'on'
])

FALSE_STRINGS = new Set([
  '0'
  'f'
  'false'
  'n'
  'no'
  'off'
])

export objToJson = (obj) ->
  JSON.stringify obj, (key, value) ->
    switch typeof value
      when 'bigint'
        # 精度落ち
        Number(value)
      when 'object'
        if value instanceof Map
          Object.fromEntries([value...])
        else if value instanceof Set
          [value...]
        else
          value
      else
        value

# convert to the specified type
export convertToType = (val, type = 'string') ->
  return val unless val?

  # オブジェクトの場合は入れ子で処理
  if typeof type == 'object'
    return pickType(val, type)

  switch type
    when 'string', 'text'
      toString(val)
    when 'boolean'
      toBoolean(val)
    when 'integer'
      toInteger(val)
    when 'float'
      toFloat(val)
    when 'datetime'
      toDateTime(val)
    when 'date'
      toDate(val)
    when 'time'
      toTime(val)
    when 'list'
      toList(val)
    when 'map'
      toMap(val)
    when 'set'
      toSet(val)
    when 'any'
      val
    else
      console.warn "cannot convert to the unknown type: #{type}"
      undefined

export toString = (val) -> String(val)

export toBoolean = (val) ->
  if typeof val == 'string'
    lowerStr = val.toLowerCase()
    if TRUE_STRINGS.has(lowerStr)
      return true
    else if FALSE_STRINGS.has(lowerStr)
      return false

  Boolean(val)

export toInteger = (val) -> Math.floor(Number(val))

export toFloat = (val) -> Number(val)

export toDateTime = (val) ->
  dateTime = switch typeof val
    when 'number'
      DateTime.fromSeconds(val)
    when 'bigint'
      DateTime.fromSeconds(Number(val))
    when 'string'
      if val
        DateTime.fromISO(val)
      else
        null
    when 'object'
      if val instanceof Date
        DateTime.fromJSDate(val)
      else if val instanceof DateTime
        val
      else
        console.warn 'no datetime object: %s', val
        DateTime.fromJSDate(Date(val))
    else
      console.warn 'no datetime object: %s', val
      DateTime.fromJSDate(Date(val))
  dateTime?.toLocal()

export toDate = (val) -> toDateTime(val)?.toISODate()

export toTime = (val) -> toDateTime(val)?.toISOTime(includeOffset: false)

export toList = (val) ->
  val = JSON.parse(val) if typeof val == 'string'
  return val if val instanceof Array

  if val[Symbol.iterator]?
    [val...]
  else if val.length?
    (v for v in val)
  else if typeof val == 'object'
    Object.entries(val)
  else
    console.warn 'no list object: %s', val
    []
    

export toMap = (val) ->
  return val if val instanceof Map

  new Map(toList(val).map((v) ->
    if typeof v == 'string'
      [v, true]
    else
      toList(v)
    )
  )

export toSet = (val) ->
  return val if val instanceof Set

  new Set(toList(val))

export updateList = (item, list, sameKey = 'id') ->
  keyValue = item[sameKey]
  for v in list
    if v[sameKey] == keyValue
      {v..., item...}
    else
      v

# URLから最後の文字列を取り出す。
# 空文字列しかない場合は undefined を返す
export getBasenameFromUrl = (url) ->
  basename(url.pathname)

export getQueryParamsFromUrl = (url) ->
  Object.fromEntries(new URLSearchParams(url.search))

export basename = (path) ->
  return '' unless path

  path.split('/').reverse().find(identity) || '/'

export entityLabel = (entity) ->
  entity.display_name || entity.name || entity.username || entity.groupname || ''


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

