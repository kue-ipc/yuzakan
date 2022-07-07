# form helper

import {listToKebab} from './string_utils.js'

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
  [for own key, value of obj
    if typeof value == 'object'
      objToUrlencodedParams(value, [parents..., key])
    else
      "#{encodeURIComponent(fieldName(key, parents))}=#{encodeURIComponent(value)}"
  ].flat()
