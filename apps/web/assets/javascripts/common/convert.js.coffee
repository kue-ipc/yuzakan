# convert from/to primitive vaule and Object, Array, Map, Set, DateTime, etc...

import {DateTime} from '/assets/vendor/luxon.js'

import {capitalize} from '/assets/common/string_helper.js'

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

export TRUE_STR = '1'
export FALSE_STR = '0'

# convert to the specified type
export convertToType = (val, type = 'string') ->
  return val unless val?

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
    when 'object'
      toObject(val)
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

export toObject = (val) ->
  if typeof val == 'string'
    JSON.parse(val) 
  else if val[Symbol.iterator]?
    Object.fromEntries(val)
  else
    Object(val)

# string -> list

# abcDef_ghi-jkl -> abc def ghi jkl
export strToList = (str) ->
  str.replace(/[A-Z]+/g, '_$&').toLowerCase().split(/[-_\s]+/)

export filedToList = (str) ->
  list = []
  list.push str.match(/^([^\[]*)/)[0]
  list.push ...str.matchAll(/\[[^\]]*\]/g)
  list

# list -> string

# abc, def, hij -> abcDefHij
export listToCamelCase = (list...) ->
  (list[0]?.toLowerCase() ? '') +
    (capitalize(str) for str in list[1..]).join('')

# abc, def, hij -> AbcDefHij
export listToPascalCase = (list...) ->
  (capitalize(str) for str in list).join('')

# abc, def, hij -> abc_def_hij
export listToSnakeCase = (list...) ->
  (str.toLowerCase() for str in list).join('_')

# abc, def, hij -> abc-def-hij
export listToKebabCase = (list...) ->
  (str.toLowerCase() for str in list).join('-')

# abc, def, hij -> ABC_DEF_HIJ
export listToAllCaps = (list...) ->
  (str.toUpperCase() for str in list).join('_')

# abc, def, hij -> Abc-Def-Hij
export listToTrainCase = (list...) ->
  (capitalize(str) for str in list).join('-')

export listToParamName = (list...) ->
  (list[0] ? '') + ("[#{str}]" for str in list[1..]).join('')

# object -> other

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

export objToRecord = (obj) ->
  toObject(objToParams(obj))

export objToParams = (obj, parents = []) ->
  obj = Object.fromEntries(obj) if obj instanceof Map
  params = []
  for own key, value of obj
    if typeof value == 'object'
      if value instanceof Map
        params.push(objToParams(toObject(value), [parents..., key])...)
      else if value instanceof Set
        params.push(objToParams(toList(value), [parents..., key])...)
      else
        params.push(objToParams(value, [parents..., key])...)
    else
      params.push([listToParamName(parents..., key), value])
  params

export objToUrlencoded = (obj) ->
  objToUrlencodedParams(obj).join('&')

export objToUrlencodedParams = (obj) ->
  for [key, value] in objToParams(obj) when value?
    "#{encodeURIComponent(key)}=#{valueToUrlencoded(value)}"

# JavaScriptの値をUrlencodedの文字列に落とし込む前に変換する
# true, fales -> 1, 0
valueToUrlencoded = (value) ->
  if !value?
    ''
  else if value == true
    '1'
  else if value == false
    '0'
  else if value instanceof Date
    encodeURIComponent(String(toDateTime(value)))
  else
    encodeURIComponent(String(value))

# other -> object

export recordToObj = (record) ->
  obj = {}
  for key, value of record
    match = key.match(/^(.+)\[([^\]]+)\]$/)
    if match
      obj[match[1]] ||= {}
      obj[match[1]][match[2]] = value
    else
      obj[key] = value
  obj
