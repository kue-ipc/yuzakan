# form helper

import {listToKebab} from '/assets/common/string_helper.js'

export listToField = (list...) ->
  (list[0] ? '') + ("[#{str}]" for str in list[1..]).join('')

export filedToList = (str) ->
  list = []
  list.push str.match(/^([^\[]*)/)[0]
  list.push ...str.matchAll(/\[[^\]]*\]/g)
  list

export fieldName = (name, parents = []) ->
  listToField(parents..., name)

export fieldId = (name, parents = []) ->
  listToKebab(parents..., name)

export formDataToObj = (formData) ->
  obj = {}
  for [key, value] from formData
    names = filedToList(key)
    curObj = obj
    for name in names[0..-2]
      curObj[name] ?= {}
      curObj = curObj[name]
    curObj[names[-1]] = value

export formDataToJson = (formData) ->
  JSON.stringify(formDataToObj(formData))

export formDataToUrlencoded = (formData) ->
  throw new Error('Not implument')

export objToUrlencoded = (obj) ->
  objToUrlencodedParams(obj).join('&')

export objToUrlencodedParams = (obj, parents = []) ->
  (for own key, value of obj
    if !value?
      undefined
    else if typeof value == 'object'
      objToUrlencodedParams(value, [parents..., key])
    else
      "#{encodeURIComponent(fieldName(key, parents))}=#{valueToUrlencoded(value)}"
  ).flat().filter((v) -> v?)

# JavaScriptの値をUrlencodedの文字列に落とし込む前に変換する
# true, fales -> 1, 0
# 日付 -> Posixタイム(秒)
export valueToUrlencoded = (value) ->
  if !value?
    ''
  else if value == true
    '1'
  else if value == false
    '0'
  else if value instanceof Date
    # Date.prototype.getTime()はミリ秒で返すため、1000で割り、整数にする
    String(value.getTime() // 1000)
  else
    encodeURIComponent(String(value))
