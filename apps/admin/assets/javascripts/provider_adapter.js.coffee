import {h, app} from './hyperapp.js'

mainNode = document.getElementById('provider-adapter')
adapters = JSON.parse(mainNode.getAttribute('data-adapters'))
initAdapter = Number.parseInt(
  mainNode.getAttribute('data-init-adapter'), 10)

getParamsByAdapter = (adapter_id) ->
  result = await fetch "/admin/adapters/#{adapter_id}/params",
    method: 'GET'
    mode: 'same-origin'
    credentials: 'same-origin'
    headers:
      accept: 'application/json'
  console.log result

AdapterSelect = (props) ->
  h 'div', class: 'form-group', [
    h 'label', for: 'provider-adapter', 'アダプター'
    h 'select', class: 'form-control', onChange: props.onSelect,
      adapters.map (adapter) ->
        if props.selected == adapter.id
          h 'option', value: adapter.id, selected: true, adapter.name
        else
          h 'option', value: adapter.id, adapter.name
  ]

Paramss = (props) ->
  h 'div', {},
    props.paramss.map (params) ->
      switch params.type
        when 'string'
          h InputString, params...
        when 'integer'
          h InputInteger, params...
        when 'boolean'
          h InputBoolean, params...
        when 'secret'
          h InputSecret, params...
        when 'list'
          h InputList, params...
        else
          raise 'パラメーターのタイプが正しくない。'

selectAdapter = (state, event) ->
  newAdapterId = Number.parseInt(event.target.value, 10)
  getParamsByAdapter newAdapterId
  {
    state...
    adapterId: newAdapterId
  }

app
  init: () -> {
    adapterId: initAdapter
  }
  view: (state) ->
    h 'div', {}, [
      h AdapterSelect,
        selected: state.adapterId
        onSelect: selectAdapter
    ]
  node: mainNode
