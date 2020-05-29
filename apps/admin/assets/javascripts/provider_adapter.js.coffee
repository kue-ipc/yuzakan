# Hyperapp v2 対応済み

import {h, app} from '../hyperapp.js'

import {fieldName, fieldId} from './form_helper.js'

mainNode = document.getElementById('provider-adapter')
adapterSelectNode = document.getElementById(
  mainNode.getAttribute('data-adapter-select'))
providerParamsData = mainNode.getAttribute('data-provider-params')

parentNames = ['provider', 'params']

if providerParamsData ? providerParamsData.length > 0
  providerParams = JSON.parse(providerParamsData)
  providerParamsSetted = true
else
  providerParams = {}
  providerParamsSetted = false

getParamsByAdapter = (adapterName) ->
  result = await fetch "/admin/adapters/#{adapterName}/params",
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
    type: 'text'
    class: 'form-control'
    value: providerParams[props.name] ? ''
  for key in ['value', 'required', 'placeholder', 'maxlength', 'minlength', 'pattern', 'size']
    inputOpts[key] = props[key] if props[key]?

  h 'div', class: 'form-group', [
    h 'label', for: id, label
    h 'input', inputOpts
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
    value: providerParams[props.name] ? ''
  for key in ['value', 'required', 'placeholder', 'max', 'min', 'step']
    inputOpts[key] = props[key] if props[key]?

  h 'div', class: 'form-group', [
    h 'label', for: id, label
    h 'input', inputOpts
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

  if props.value ? providerParams[props.name]
    inputOpts['checked'] = true

  h 'div', class: 'form-check', [
    h 'input', hiddenInputOpts
    h 'input', inputOpts
    h 'label', class: 'form-check-label', for: id, label
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
  ]


Params = (props) ->
  h 'div', {},
    if props.params
      props.params.map (param) ->
        if param.list?
          h InputList, {param...}
        else
          switch param.type
            when 'string'
              h InputString, {param...}
            when 'secret'
              h InputSecret, {param...}
            when 'integer'
              h InputInteger, {param...}
            when 'boolean'
              h InputBoolean, {param...}
            else
              'none'
    else
      "パラメーター一覧が表示されるまでお待ち下さい。"

state =
  params: []

changeSelectRunner = (dispatch, {action, node}) ->
  updateAsyncFunc = (value) ->
    params = await getParamsByAdapter(value)
    dispatch(action, params)
  func = (event) ->
    updateAsyncFunc(event.target.value)
    (->
      params = await getParamsByAdapter()
      dispatch(action, params)
    )()
  updateAsyncFunc(node.value)
  node.addEventListener 'change', func
  () -> node.removeListener 'change', func

changeSelect = (action, {node}) ->
  [
    changeSelectRunner
    {action, node}
  ]

updateParams = (state, value) ->
  params: value

view = (state) ->
  h 'div', {}, [
    h 'p', {}, 'パラメーター'
    h Params,
      params: state.params
  ]

app
  init: state
  view: view
  node: mainNode
  subscriptions: (state) -> changeSelect(updateParams, node: adapterSelectNode)
