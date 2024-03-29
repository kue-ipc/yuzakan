# form helper

import {listToKebabCase, listToParamName} from '~/common/convert.js'

export formName = (name, parents = []) ->
  listToParamName(parents..., name)

export formId = (name, parents = []) ->
  listToKebabCase(parents..., name)

export formDataToObj = (formData) ->
  root = {}
  for [key, value] from formData
    keyList = paramNameToList(key)
    obj = root
    while subKey = keyList.shift()
      if keyList.length == 0
        obj[subKey] = value
      else
        if keyList[0] == ''
          throw new Error('Empty key must be last') unless keyList.length == 1
          obj[subKey] ?= []
          obj[subKey].push value
        else if keyList[0].match(/^\d+$/)
          obj[subKey] ?= []
        else
          obj[subKey] ?= {}
        obj = obj[subKey]

  root

export formDataToJson = (formData) ->
  JSON.stringify(formDataToObj(formData))

export formDataToUrlencoded = (formData) ->
  throw new Error('Not implument')

