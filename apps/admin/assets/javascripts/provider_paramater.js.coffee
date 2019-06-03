import {h, app} from './hyperapp.js'

providerParamaterEl = document.getElementById('provider-paramater')
adapters = JSON.parse(providerParamaterEl.getAttribute('data-adapters'))
initAdapter = Number.parseInt(
  providerParamaterEl.getAttribute('data-init-adapter'), 10)

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

selectAdapter = (state, event) -> {
  state...
  adapterId: event.target.value
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
  node: providerParamaterEl
