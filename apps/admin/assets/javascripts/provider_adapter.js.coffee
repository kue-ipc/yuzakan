# Hyperapp v1
# v2はまだ手を出すのが早かった模様

import {h, app} from './hyperapp.js'

mainNode = document.getElementById('provider-adapter')
adapters = JSON.parse(mainNode.getAttribute('data-adapters'))
initAdapter =
  if mainNode.getAttribute('data-init-adapter')
    Number.parseInt(mainNode.getAttribute('data-init-adapter'), 10)
  else
    adapters[0].id


getParamsByAdapter = (adapter_id) ->
  result = await fetch "/admin/adapters/#{adapter_id}/params",
    method: 'GET'
    mode: 'same-origin'
    credentials: 'same-origin'
    headers:
      accept: 'application/json'
  result.json()

AdapterSelect = (props) ->
  h 'div', class: 'form-group', [
    h 'label', for: 'provider[adapter_id]', 'アダプター'
    h 'select',
      class: 'form-control',
      name: 'provider[adapter_id]',
      onchange: (event) =>
        props.onselect(event.target.value)
      ,
      adapters.map (adapter) ->
        if props.selected == adapter.id
          h 'option', value: adapter.id, selected: true, adapter.name
        else
          h 'option', value: adapter.id, adapter.name
  ]

InputString = (props) ->
  title = props.title
  name = "provider[params][#{props.name}]"

  inputOpts =
    name: name
    type: 'text'
    class: 'form-control'
  for key in ['value', 'required', 'placeholder', 'maxlength', 'minlength', 'pattern', 'size']
    inputOpts[key] = props[key] if props[key]?

  h 'div', class: 'form-group', [
    h 'label', for: name, title
    h 'input', inputOpts
  ]

InputInteger = (props) ->
  title = props.title
  name = "provider[params][#{props.name}]"

  inputOpts =
    name: name
    type: 'number'
    class: 'form-control'
  for key in ['value', 'required', 'placeholder', 'max', 'min', 'step']
    inputOpts[key] = props[key] if props[key]?

  h 'div', class: 'form-group', [
    h 'label', for: name, title
    h 'input', inputOpts
  ]

InputBoolean = (props) ->
  title = props.title
  name = "provider[params][#{props.name}]"

  inputOpts =
    name: name
    type: 'checkbox'
    class: 'form-control'
    volue: '1'
  if props.value
    inputOpts['checked'] = true

  h 'div', class: 'form-group', [
    h 'label', for: name, title
    h 'input', inputOpts
  ]


InputSecret = (props) ->
  title = props.title
  name = "provider[params][#{props.name}]"

  inputOpts =
    name: name
    type: 'password'
    class: 'form-control'
  for key in ['value', 'required', 'placeholder', 'maxlength', 'minlength', 'pattern', 'size']
    inputOpts[key] = props[key] if props[key]?

  h 'div', class: 'form-group', [
    h 'label', for: name, title
    h 'input', inputOpts
  ]

InputList = (props) ->
  title = props.title
  name = "provider[params][#{props.name}]"

  selected = props.value ? props.default

  h 'div', class: 'form-group', [
    h 'label', for: name, title
    h 'select',
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
            when 'integer'
              h InputInteger, {param...}
            when 'boolean'
              h InputBoolean, {param...}
            when 'secret'
              h InputSecret, {param...}
            else
              'none'
    else
      "パラメーター一覧が表示されるまでお待ち下さい。"


# selectAdapter = (state, event) ->
#   newAdapterId = Number.parseInt(event.target.value, 10)
#   {
#     state...
#     adapterId: newAdapterId
#   }


state =
  adapterId: initAdapter
  params: []

actions =
  selectAdapter: (value) => (state, actions) =>
    newAdapterId = Number.parseInt(value, 10)
    actions.updateAdapterId(newAdapterId)
    params = await getParamsByAdapter(newAdapterId)
    actions.updateParams(params)
  updateAdapterId: (value) => (state) =>
    adapterId: value
  updateParams: (value) => (satte) =>
    params: value

view = (state, actions) ->
  h 'div', {}, [
    h AdapterSelect,
      selected: state.adapterId
      onselect: actions.selectAdapter
    h 'p', {}, 'パラメーター'
    h Params,
      params: state.params
  ]

main = app(state, actions, view, mainNode)

main.selectAdapter(initAdapter)
