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
    }
    select {class: 'form-control'},
      mappingConversions.map (conversion) ->
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
      }
      input {
        class: 'form-control'
        type: 'text'
        value: attr.label
        required: true
      }
    ]
    td {class: 'table-primary'}, [
      select {class: 'form-control'},
        attrTypes.map (attrType) ->
          option {
            value: attrType.value
            selected: attrType.value == attr.type
          }, text attrType.label
      input {
        type: 'checkbox'
        class: 'form-check-input'
        checked: attr.hidden
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
          }, text '削除'
        ]
      else
        [
          div {class: 'mb-1'},
            button {
              class: 'btn btn-primary'
            }, text '作成'
        ]
  ].concat(providers.map (provider) -> attrMappingTd({attr, provider}))

updateAttrRunner = (dispatch, {attr}) ->
  {newName, name, attr...} = attr
  attr = {attr..., name: newName} if newName?
  response = await fetchJsonPatch({url: "/api/attrs/#{name}", data: {csrf()..., attr...}})
  if response.ok
    dispatch(getAttrAction, {name: name, attr: response.data})
  else
    console.error response


getAttrAction = (state, {name, attr}) ->
  name ?= attr.name
  attrs = state.attrs.map (currentAttr) ->
    if currentAttr.name == name
      attr
    else
      currentAttr
  {state..., attrs}

getAttrRunner = (dispatch, {attr}) ->
  response = await fetchJsonGet({url: "/api/attrs/#{attr.name}"})
  if response.ok
    dispatch(getAttrAction, {attr: response.data})
  else
    console.error response

getAllAttrsAction = (state, {attrs}) ->
  [{state..., attrs}].concat(attrs.map (attr) -> [getAttrRunner, {attr}])

getAllAttrsRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/attrs'})
  if response.ok
    dispatch(getAllAttrsAction, {attrs: response.data})
  else
    console.error response

getAllProvidersAction = (state, {providers}) ->
  {state..., providers}

getAllProvidersRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/providers'})
  if response.ok
    dispatch(getAllProvidersAction, {providers: response.data})
  else
    console.error response

init = [
  {
    attrs: []
    providers: []
  }
  [getAllAttrsRunner]
  [getAllProvidersRunner]
]

view = (state) ->
  newAttr = {
    name: ''
    label: ''
    type: 'string'
    hidden: false
    attr_mappings: []
  }
  table {class: 'table'}, [
    thead {}, [
      tr {class: 'text-center'}, [
        th {}, text '順番'
        th {}, text '名前/表示名'
        th {}, text '型/隠し'
        th {}, text '操作'
      ].concat(state.providers.map (provider) -> providerTh({provider}))
    ]
    tbody {},
      [state.attrs..., newAttr].map (attr, index) -> attrTr({attr, index, providers: state.providers})
  ]

node = document.getElementById('admin_attrs_index')

app {init, view, node}



