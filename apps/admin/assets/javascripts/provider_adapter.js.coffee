# Hyperapp v1
# v2はまだ手を出すのが早かった模様

import {h, app} from './hyperapp.js'

mainNode = document.getElementById('provider-adapter')
adapterSelectNode = document.getElementById(
  mainNode.getAttribute('data-adapter-select'))
# params = JSON.parse(mainNode.getAttribute('data-params'))

# initAdapter =
#   if mainNode.getAttribute('data-init-adapter')
#     Number.parseInt(mainNode.getAttribute('data-init-adapter'), 10)
#   else
#     adapters[0].id


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
  name = "provider[params][#{props.name}]"
  id = "provider-params-#{props.name}]"

  inputOpts =
    id: id
    name: name
    type: 'text'
    class: 'form-control'
  for key in ['value', 'required', 'placeholder', 'maxlength', 'minlength', 'pattern', 'size']
    inputOpts[key] = props[key] if props[key]?

  h 'div', class: 'form-group', [
    h 'label', for: id, label
    h 'input', inputOpts
  ]

InputSecret = (props) ->
  label = props.label
  name = "provider[params][#{props.name}]"
  id = "provider-params-#{props.name}]"

  inputOpts =
    id: id
    name: name
    type: 'password'
    class: 'form-control'
  for key in ['value', 'required', 'placeholder', 'maxlength', 'minlength', 'pattern', 'size']
    inputOpts[key] = props[key] if props[key]?

  h 'div', class: 'form-group', [
    h 'label', for: id, label
    h 'input', inputOpts
  ]

InputInteger = (props) ->
  label = props.label
  name = "provider[params][#{props.name}]"
  id = "provider-params-#{props.name}]"

  inputOpts =
    id: id
    name: name
    type: 'number'
    class: 'form-control'
  for key in ['value', 'required', 'placeholder', 'max', 'min', 'step']
    inputOpts[key] = props[key] if props[key]?

  h 'div', class: 'form-group', [
    h 'label', for: id, label
    h 'input', inputOpts
  ]

InputBoolean = (props) ->
  label = props.label
  name = "provider[params][#{props.name}]"
  id = "provider-params-#{props.name}]"

  inputOpts =
    id: id
    name: name
    type: 'checkbox'
    class: 'form-check-input'
    volue: '1'

  if props.value
    inputOpts['checked'] = true

  h 'div', class: 'form-check', [
    h 'input', inputOpts
    h 'label', class: 'form-check-label', for: id, label
  ]

InputList = (props) ->
  label = props.label
  name = "provider[params][#{props.name}]"
  id = "provider-params-#{props.name}]"

  selected = props.value ? props.default

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

actions =
  selectAdapter: (value) => (state, actions) =>
    params = await getParamsByAdapter(value)
    actions.updateParams(params)
  updateParams: (value) => (satte) =>
    params: value

view = (state, actions) ->
  h 'div', {}, [
    h 'p', {}, 'パラメーター'
    h Params,
      params: state.params
  ]

mainApp = app(state, actions, view, mainNode)

mainApp.selectAdapter(adapterSelectNode.value)
adapterSelectNode.addEventListener 'change', (event) ->
  mainApp.selectAdapter(event.target.value)
