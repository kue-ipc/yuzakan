# Hyperapp v2 対応済み

import {h, app} from '../hyperapp.js'

import {fieldName, fieldId} from './form_helper.js'

mainNode = document.getElementById('provider-adapter')
adapterSelectNode = document.getElementById(
  mainNode.getAttribute('data-adapter-select'))
providerIdData = mainNode.getAttribute('data-provider-id')

providerId = 
  if providerIdData ? providerIdData.length > 0
    providerIdData
  else
    undefined

parentNames = ['provider', 'params']

getAdapterParams = (adapterName) ->
  result = await fetch "/admin/adapters/#{adapterName}/params",
    method: 'GET'
    mode: 'same-origin'
    credentials: 'same-origin'
    headers:
      accept: 'application/json'
  result.json()

getProviderParams = (providerId) ->
  result = await fetch "/admin/providers/#{providerId}/params",
    method: 'GET'
    mode: 'same-origin'
    credentials: 'same-origin'
    headers:
      accept: 'application/json'
  result.json()

InputString = (props) ->
  label = props.label
  name = fieldName(props.name, parentNames)
  id = fieldId(props.name, parentNames)

  inputOpts =
    id: id
    name: name
    type: props.type ? 'text'
    class: 'form-control'
    value: props.value

  for key in ['value', 'required', 'placeholder', 'maxlength', 'minlength', 'pattern', 'size']
    inputOpts[key] = props[key] if props[key]?

  h 'div', class: 'form-group', [
    h 'label', for: id, label
    h 'input', inputOpts
    h 'small', class: 'form-text text-muted', props['description']
  ]

InputSecret = (props) ->
  label = props.label
  name = fieldName(props.name, parentNames)
  id = fieldId(props.name, parentNames)

  inputOpts =
    id: id
    name: name
    type: 'password'
    class: 'form-control'

  for key in ['value', 'required', 'placeholder', 'maxlength', 'minlength', 'pattern', 'size']
    inputOpts[key] = props[key] if props[key]?
  if providerParamsSetted
    inputOpts['required'] = false

  h 'div', class: 'form-group', [
    h 'label', for: id, label
    h 'input', inputOpts
    h 'small', class: 'form-text text-muted', props['description']
  ]

InputInteger = (props) ->
  label = props.label
  name = fieldName(props.name, parentNames)
  id = fieldId(props.name, parentNames)

  inputOpts =
    id: id
    name: name
    type: 'number'
    class: 'form-control'
    value: props.value

  for key in ['value', 'required', 'placeholder', 'max', 'min', 'step']
    inputOpts[key] = props[key] if props[key]?

  h 'div', class: 'form-group', [
    h 'label', for: id, label
    h 'input', inputOpts
    h 'small', class: 'form-text text-muted', props['description']
  ]

InputBoolean = (props) ->
  label = props.label
  name = fieldName(props.name, parentNames)
  id = fieldId(props.name, parentNames)

  hiddenInputOpts =
    name: name
    type: 'hidden'
    value: '0'

  inputOpts =
    id: id
    name: name
    type: 'checkbox'
    class: 'form-check-input'
    value: '1'

  if props.value
    inputOpts['checked'] = true

  h 'div', class: 'form-check', [
    h 'input', hiddenInputOpts
    h 'input', inputOpts
    h 'label', class: 'form-check-label', for: id, label
    h 'small', class: 'form-text text-muted', props['description']
  ]

InputList = (props) ->
  label = props.label
  name = fieldName(props.name, parentNames)
  id = fieldId(props.name, parentNames)

  selected = props.value ? providerParams[props.name] ? props.default

  h 'div', class: 'form-group', [
    h 'label', for: id, label
    h 'select',
      id: id
      class: 'form-control',
      name: name,
      props.list.map (option) ->
        if selected == option.value
          h 'option', value: option.value, selected: true, option.name
        else
          h 'option', value: option.value, option.name
    h 'small', class: 'form-text text-muted', props['description']
  ]


Params = ({adapterParams, providerParams}) ->
  h 'div', {},
    if adapterParams.length > 0
      adapterParams.map (param) ->
        value = providerParams[param.name]
        if param.list?
          h InputList, {param..., value}
        else
          switch param.type
            when 'string'
              h InputString, {param..., value}
            when 'secret'
              h InputSecret, {param..., value}
            when 'integer'
              h InputInteger, {param..., value}
            when 'boolean'
              h InputBoolean, {param..., value}
            else
              'none'
    else
      "設定できるパラメーターはありません。"

updateAdapterParams = (state, value) -> {
  state...
  adapterParams: value
}

updateProviderParams = (state, value) -> {
  state...
  providerParams: value
}

changeSelectRunner = (dispatch, {node}) ->
  updateAsyncFunc = (value) ->
    params = await getAdapterParams(value)
    dispatch(updateAdapterParams, params)

  updateAsyncFunc(node.value)

  node.addEventListener 'change', (event) ->
    updateAsyncFunc(event.target.value)

providerRunner = (dispatch, {providerId}) ->
  return unless providerId?
  params = await getProviderParams(providerId)
  dispatch(updateProviderParams, params)

initState =
  adapterParams: []
  providerParams: {}

view = (state) ->
  h 'div', {}, [
    h 'p', {}, 'パラメーター'
    h Params, state
  ]

app
  init: [
    initState
    [
      providerRunner
      providerId: providerId
    ]
    [
      changeSelectRunner
      node: adapterSelectNode
    ]
  ]
  view: view
  node: mainNode
