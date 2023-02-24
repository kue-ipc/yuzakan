# form helper

import {listToKebabCase, listToParamName} from '/assets/common/convert.js'

export formName = (name, parents = []) ->
  listToParamName(parents..., name)

export formId = (name, parents = []) ->
  listToKebabCase(parents..., name)

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

