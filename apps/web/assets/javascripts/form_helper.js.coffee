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
