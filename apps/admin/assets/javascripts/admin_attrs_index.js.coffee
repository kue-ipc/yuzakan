import {h, text, app} from '../hyperapp.js?v=6.0.0'
import {div, table, thead, tbody, tr, th, td, input, select, option, button} from '../hyperapp-html.js?v=0.6.0'
import {fetchJsonGet, fetchJsonPost, fetchJsonPatch, fetchJsonDelete} from '../fetch_json.js?v=0.6.0'
import csrf from '../csrf.js?v=0.6.0'

attrTypes = [
  {name: 'string', value: 'string', label: '文字列'}
  {name: 'boolean', value: 'boolean', label: '真偽'}
  {name: 'integer', value: 'integer', label: '整数'}
  {name: 'float', value: 'float', label: '小数点数'}
  {name: 'datetime', value: 'datetime', label: '日時'}
  {name: 'date', value: 'date', label: '日付'}
  {name: 'time', value: 'time', label: '時刻'}
]

mappingConversions = [
  {name: '', value: null, label: '変換無し'}
  {name: 'posix_time', value: 'posix_time', label: 'POSIX時間'}
  {name: 'posix_date', value: 'posix_date', label: 'POSIX日付'}
  {name: 'path', value: 'path', label: 'PATH(パス)'}
  {name: 'e2j', value: 'e2j', label: '英日'}
  {name: 'j2e', value: 'j2e', label: '日英'}
]

providerTh = ({provider}) ->
  th {}, text provider.label

attrMappingTd = ({attr, provider}) ->
  unless attr.attr_mappings?
    return td {}, text '読み込み中'

  mapping = attr.attr_mappings.find (attr_mapping) ->
    attr_mapping.provider.name == provider.name
  mapping ?= {name: '', conversion: null}

  td {}, [
    input {
      class: 'form-control mb-1'
      type: 'text'
      value: mapping.name
      oninput: (state, event) ->
        [
          attrMappingAction
          {name: attr.name, attr_mapping: {name: event.target.value, provider: {name: provider.name}}}
        ]
    }
    select {
      class: 'form-control'
      oninput: (state, event) ->
        [
          attrMappingAction
          {name: attr.name, attr_mapping: {conversion: event.target.value, provider: {name: provider.name}}}
        ]
      }, mappingConversions.map (conversion) ->
        option {
          value: conversion.value
          selected: conversion.value == mapping.conversion
        }, text conversion.label
  ]

attrTr = ({attr, index, providers}) ->
  tr {}, [
    td {},
      if attr.order
        [
          div {class: 'mb-1'}, button {
            class: 'btn btn-secondary'
          }, text '上'
          div {}, button {
            class: 'btn btn-secondary'
          }, text '下'
        ]
    td {class: 'table-primary'}, [
      input {
        class: 'form-control mb-1'
        type: 'text'
        value: attr.newName ? attr.name
        required: true
        oninput: (state, event) -> [attrAction, {name: attr.name, attr: {newName: event.target.value}}]
      }
      input {
        class: 'form-control'
        type: 'text'
        value: attr.label
        required: true
        oninput: (state, event) -> [attrAction, {name: attr.name, attr: {label: event.target.value}}]
      }
    ]
    td {class: 'table-primary'}, [
      select {
        class: 'form-control'
        onchange: (state, event) -> [attrAction, {name: attr.name, attr: {type: event.target.value}}]
      },
        attrTypes.map (attrType) ->
          option {
            value: attrType.value
            selected: attrType.value == attr.type
          }, text attrType.label
      input {
        type: 'checkbox'
        class: 'form-check-input'
        checked: attr.hidden
        onchange: (state, event) -> [attrAction, {name: attr.name, attr: {hidden: !attr.hidden}}]
      }
    ]
    td {},
      if attr.order
        [
          div {class: 'mb-1'}, button {
            class: 'btn btn-warning'
            onclick: (state) -> [state, [updateAttrRunner, {attr}]]
          }, text '更新'
          div {}, button {
            class: 'btn btn-danger'
            onclick: (state) -> [state, [destroyAttrRunner, {attr}]]
          }, text '削除'
        ]
      else
        [
          div {class: 'mb-1'}, button {
            class: 'btn btn-primary'
            onclick: (state) -> [state, [createAttrRunner, {attr}]]
          }, text '作成'
        ]
  ].concat(providers.map (provider) -> attrMappingTd({attr, provider}))

attrAction = (state, {name, attr}) ->
  name ?= attr.name
  if name
    replaced = false
    attrs = state.attrs.map (currentAttr) ->
      if currentAttr.name == name
        replaced = true
        {currentAttr..., attr...}
      else
        currentAttr
    unless replaced
      attrs = [attrs..., attr]
    {state..., attrs}
  else
    {state..., newAttr: {state.newAttr..., attr...}}

deleteAttrAction = (state, {name}) ->
  attrs = state.attrs.filter (attr) -> attr.name != name
  {state..., attrs}

replaceAttrMapping = (attr_mappings, attr_mapping) ->
  replaced = false
  new_attr_mappings = attr_mappings.map (current_mapping) ->
    if current_mapping.provider.name == attr_mapping.provider.name
      replaced = true
      {current_mapping..., attr_mapping...}
    else
      current_mapping

  if replaced
    new_attr_mappings
  else
    [new_attr_mappings..., {name: '', conversion: null, attr_mapping...}]

attrMappingAction = (state, {name, attr_mapping}) ->
  if name
    attrs = state.attrs.map (attr) ->
      if attr.name == name
        {attr..., attr_mappings: replaceAttrMapping(attr.attr_mappings, attr_mapping)}
      else
        attr
    {state..., attrs}
  else
    {
      state...
      newAttr: {state.newAttr..., attr_mappings: replaceAttrMapping(state.newAttr.mappings, attr_mapping)}
    }

createAttrRunner = (dispatch, {attr}) ->
  {name, newName, attr...} = attr
  attr = {attr..., name: newName}
  response = await fetchJsonPost({url: "/api/attrs", data: {csrf()..., attr...}})
  if response.ok
    dispatch(attrAction, {attr: response.data})
    dispatch(attrAction, {attr: initNewAttr})
  else
    console.error response

updateAttrRunner = (dispatch, {attr}) ->
  {name, newName, attr...} = attr
  attr = {attr..., name: newName} if newName?
  response = await fetchJsonPatch({url: "/api/attrs/#{name}", data: {csrf()..., attr...}})
  if response.ok
    dispatch(attrAction, {name, attr: {response.data..., newName: undefined}})
  else
    console.error response

destroyAttrRunner = (dispatch, {attr}) ->
  response = await fetchJsonDelete({url: "/api/attrs/#{attr.name}", data: csrf()})
  if response.ok
    dispatch(deleteAttrAction, {name: attr.name})
  else
    console.error response






showAttrRunner = (dispatch, {attr}) ->
  response = await fetchJsonGet({url: "/api/attrs/#{attr.name}"})
  if response.ok
    dispatch(attrAction, {attr: response.data})
  else
    console.error response

initAllAttrsAction = (state, {attrs}) ->
  [{state..., attrs}].concat(attrs.map (attr) -> [showAttrRunner, {attr}])

indexAllAttrsRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/attrs'})
  if response.ok
    dispatch(initAllAttrsAction, {attrs: response.data})
  else
    console.error response

initAllProvidersAction = (state, {providers}) ->
  {state..., providers}

indexAllProvidersRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/providers'})
  if response.ok
    dispatch(initAllProvidersAction, {providers: response.data})
  else
    console.error response

initNewAttr = {
  name: undefined
  newName: ''
  label: ''
  type: 'string'
  hidden: false
  attr_mappings: []
}

init = [
  {
    attrs: []
    providers: []
    newAttr: initNewAttr
  }
  [indexAllAttrsRunner]
  [indexAllProvidersRunner]
]

view = ({attrs, providers, newAttr}) ->
  table {class: 'table'}, [
    thead {}, [
      tr {class: 'text-center'}, [
        th {}, text '順番'
        th {}, text '名前/表示名'
        th {}, text '型/隠し'
        th {}, text '操作'
      ].concat(providers.map (provider) -> providerTh({provider}))
    ]
    tbody {},
      [attrs..., newAttr].map (attr, index) -> attrTr({attr, index, providers: providers})
  ]

node = document.getElementById('admin_attrs_index')

app {init, view, node}



