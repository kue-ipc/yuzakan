# プロバイダーのアダプター選択時にフォームを表示する

import {h, text, app} from '../hyperapp.js'
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

InputControl = (props) ->
  label = props.label
  name = fieldName(props.name, parentNames)
  id = fieldId(props.name, parentNames)
  describeId = "#{id}-help"

  inputOpts =
    id: id
    name: name
    type: props.input
    class: 'form-control'
    value: props.value ? (if props.encrypted? then props.default else '')
    'aria-edscribedby': describeId

  for key in [
    'required', 'placeholder', 'maxlength', 'minlength', 'pattern', 'size'
     'max', 'min', 'step'
  ]
    inputOpts[key] = props[key] if props[key]?

  if providerId?
    inputOpts['required'] = false

  h 'div', class: 'mb-3', [
    h 'label', class: 'form-label', for: id,
      text label
    h 'input', inputOpts
    if props.encrypted? then h 'small', class: 'form-text',
      text '''
      この項目は暗号化されて保存され、現在の値は表示されません。
      変更しない場合は、空欄のままにしてください。
      '''
    if props.description? then h 'small',
      id: describeId, class: 'form-text',
      text props.description
  ]

InputCheckbox = (props) ->
  label = props.label
  name = fieldName(props.name, parentNames)
  id = fieldId(props.name, parentNames)
  describeId = "#{id}-help"

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
    'aria-edscribedby': describeId

  if props.value
    inputOpts['checked'] = true

  h 'div', class: 'form-check', [
    h 'input', hiddenInputOpts
    h 'input', inputOpts
    h 'label', class: 'form-check-label', for: id,
      text label
    if props.description? then h 'small',
      id: describeId, class: 'form-text',
      text props.description
  ]

InputTextarea = (props) ->
  label = props.label
  name = fieldName(props.name, parentNames)
  id = fieldId(props.name, parentNames)
  describeId = "#{id}-help"

  inputOpts =
    id: id
    name: name
    class: 'form-control'
    value: props.value ? (if props.encrypted? then props.default else '')
    'aria-edscribedby': describeId

  for key in [
    'required', 'placeholder', 'maxlength', 'minlength', 'cols', 'rows'
  ]
    inputOpts[key] = props[key] if props[key]?

  if providerId?
    inputOpts['required'] = false

  h 'div', class: 'mb-3', [
    h 'label', class: 'form-label', for: id,
      text label
    h 'textarea', inputOpts
    if props.encrypted? then h 'small', class: 'form-text',
      text '''
      この項目は暗号化されて保存され、現在の値は表示されません。
      変更しない場合は、空欄のままにしてください。
      '''
    if props.description? then h 'small',
      id: describeId,
      class: 'form-text',
      text props.description
  ]

InputList = (props) ->
  label = props.label
  name = fieldName(props.name, parentNames)
  id = fieldId(props.name, parentNames)
  describeId = "#{id}-help"

  selected = props.value ? props.default

  h 'div', class: 'mb-3', [
    h 'label', class: 'form-label', for: id,
      text label
    h 'select',
      id: id
      class: 'form-control',
      name: name,
      'aria-edscribedby': describeId,
      props.list.map (option) ->
        if selected == option.value
          h 'option', value: option.value, selected: true,
            text option.name
        else
          h 'option', value: option.value,
            text option.name
      if props.description? then h 'small',
        id: describeId, class: 'form-text',
        text props.description
  ]


Params = ({adapterParams, providerParams}) ->
  h 'div', {},
    if adapterParams.length > 0
      adapterParams.map (param) ->
        value = providerParams[param.name]
        if param.list?
          return InputList {param..., value}

        input = param.input ? switch param.type
          when 'boolean' then 'checkbox'
          when 'string' then 'text'
          when 'text' then 'textarea'
          when 'integer' then 'number'
          when 'float' then 'number'
          when 'date' then 'date'
          when 'time' then 'time'
          when 'datetime' then 'datetime-local'
          when 'file' then 'file'

        switch input
          when 'text', 'password', 'email', 'searh', 'tel', 'url', \
               'number', 'range', 'color', \
               'date', 'time', 'datetime-local', 'month', 'week'
            InputControl {param..., input, value}
          when 'checkbox'
            InputCheckbox {param..., input, value}
          when 'textarea'
            InputTextarea {param..., input, value}
          else
            text '未実装の形式です。'
    else
      text "設定できるパラメーターはありません。"

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
    h 'p', {},
      text 'パラメーター'
    Params state
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
