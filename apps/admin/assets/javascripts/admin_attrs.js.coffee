import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'
import {fetchJsonGet, fetchJsonPost, fetchJsonPatch, fetchJsonDelete} from '../fetch_json.js'
import csrf from '../csrf.js'
import ConfirmDialog from '../confirm_dialog.js'

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

deleteConfirm = new ConfirmDialog {
  id: 'admin_attrs_confirm'
  status: 'alert'
  title: '属性の削除'
  message: '属性を削除してもよろしいですか？'
  action: {
    color: 'danger'
    label: '削除'
  }
}

providerTh = ({provider}) ->
  html.th {}, text provider.label

attrMappingTd = ({attr, provider}) ->
  unless attr.attr_mappings?
    return html.td {}, text '読み込み中'

  mapping = attr.attr_mappings.find (attr_mapping) ->
    attr_mapping.provider.name == provider.name
  mapping ?= {name: '', conversion: null}

  html.td {}, [
    html.input {
      class: 'form-control mb-1'
      type: 'text'
      value: mapping.name
      oninput: (state, event) ->
        [
          attrMappingAction
          {name: attr.name, attr_mapping: {name: event.target.value, provider: {name: provider.name}}}
        ]
    }
    html.select {
      class: 'form-control'
      oninput: (state, event) ->
        [
          attrMappingAction
          {name: attr.name, attr_mapping: {conversion: event.target.value, provider: {name: provider.name}}}
        ]
      }, mappingConversions.map (conversion) ->
        html.option {
          value: conversion.value
          selected: conversion.value == mapping.conversion
        }, text conversion.label
  ]

attrTr = ({attr, index, providers}) ->
  html.tr {}, [
    html.td {},
      if attr.order
        [
          html.div {class: 'mb-1'}, html.button {
            class: 'btn btn-secondary'
            onclick: (state) -> [upAttrAction, {name: attr.name}]
          }, text '上'
          html.div {}, html.button {
            class: 'btn btn-secondary'
            onclick: (state) -> [downAttrAction, {name: attr.name}]
          }, text '下'
        ]
    html.td {class: 'table-primary'}, [
      html.input {
        class: 'form-control mb-1'
        type: 'text'
        value: attr.newName ? attr.name
        required: true
        oninput: (state, event) -> [attrAction, {name: attr.name, attr: {newName: event.target.value}}]
      }
      html.input {
        class: 'form-control'
        type: 'text'
        value: attr.label
        required: true
        oninput: (state, event) -> [attrAction, {name: attr.name, attr: {label: event.target.value}}]
      }
    ]
    html.td {class: 'table-primary'}, [
      html.select {
        class: 'form-control'
        onchange: (state, event) -> [attrAction, {name: attr.name, attr: {type: event.target.value}}]
      }, attrTypes.map (attrType) ->
        html.option {
          value: attrType.value
          selected: attrType.value == attr.type
        }, text attrType.label
      html.input {
        type: 'checkbox'
        class: 'form-check-input'
        checked: attr.hidden
        onchange: (state, event) -> [attrAction, {name: attr.name, attr: {hidden: !attr.hidden}}]
      }
    ]
    html.td {},
      if attr.order
        [
          html.div {class: 'mb-1'}, html.button {
            class: 'btn btn-warning'
            onclick: (state) -> [state, [updateAttrRunner, {attr}]]
          }, text '更新'
          html.div {}, html.button {
            class: 'btn btn-danger'
            onclick: (state) -> [state, [destroyAttrRunner, {attr}]]
          }, text '削除'
        ]
      else
        [
          html.div {class: 'mb-1'}, html.button {
            class: 'btn btn-primary'
            onclick: (state) -> [state, [createAttrRunner, {attr}]]
          }, text '作成'
        ]
    (attrMappingTd({attr, provider}) for provider in providers)...
  ]

attrAction = (state, {name, attr}) ->
  name ?= attr.name
  if name
    replaced = false
    attrs = for current in state.attrs
      if current.name == name
        replaced = true
        {current..., attr...}
      else
        current
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
  new_attr_mappings = for current in attr_mappings
    if current.provider.name == attr_mapping.provider.name
      replaced = true
      {current..., attr_mapping...}
    else
      current

  if replaced
    new_attr_mappings
  else
    [new_attr_mappings..., {name: '', conversion: null, attr_mapping...}]

attrMappingAction = (state, {name, attr_mapping}) ->
  if name
    attrs = for attr in state.attrs
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
  confirm = await deleteConfirm.confirmPromise({message: "属性「#{attr.name}」を削除してもよろしいですか？"})
  if confirm
    response = await fetchJsonDelete({url: "/api/attrs/#{attr.name}", data: csrf()})
    if response.ok
      dispatch(deleteAttrAction, {name: attr.name})
    else
      console.error response

upAttrAction = (state, {name}) ->
  attrIndex = state.attrs.findIndex (attr) -> attr.name == name
  diffOrder =
    switch attrIndex
      when 0
        1
      when 1
        state.attrs[0].order
      else
        state.attrs[attrIndex - 1].order - state.attrs[attrIndex - 2].order

  if diffOrder == 1
    console.log '隙間がありません。'
    return state
 
  newAttr = {state.attrs[attrIndex]..., order: state.attrs[attrIndex - 1].order - Math.floor(diffOrder / 2)}
  [
    {
      state...
      attrs: [
        state.attrs[...(attrIndex - 1)]...
        newAttr
        state.attrs[attrIndex - 1]
        state.attrs[(attrIndex + 1)..]...
      ]
    }
    [updateAttrRunner, {attr: newAttr}]
  ]

downAttrAction = (state, {name}) ->
  attrIndex = state.attrs.findIndex (attr) -> attr.name == name
  diffOrder =
    switch attrIndex
      when state.attrs.length - 1, state.attrs.length - 2
        16
      else
        diffOreder = state.attrs[attrIndex + 2].order - state.attrs[attrIndex + 1].order

  if diffOrder == 1
    console.log '隙間がありません。'
    return state
 
  newAttr = {
    state.attrs[attrIndex]...
    order: (state.attrs[attrIndex + 1]?.order ? state.attrs[attrIndex].order) + diffOrder // 2}
  [
    {
      state...
      attrs: [
        state.attrs[...attrIndex]...
        state.attrs[attrIndex + 1]
        newAttr
        state.attrs[(attrIndex + 2)..]...
      ].filter (_) -> _?
    }
    [updateAttrRunner, {attr: newAttr}]
  ]
showAttrRunner = (dispatch, {attr}) ->
  response = await fetchJsonGet({url: "/api/attrs/#{attr.name}"})
  if response.ok
    dispatch(attrAction, {attr: response.data})
  else
    console.error response

initAllAttrsAction = (state, {attrs}) ->
  [
    {state..., attrs}
    ([showAttrRunner, {attr}] for attr in attrs)...
  ]

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
  html.table {class: 'table'}, [
    html.thead {}, [
      html.tr {}, [
        html.th {}, text '順番'
        html.th {}, text '名前/表示名'
        html.th {}, text '型/隠し'
        html.th {}, text '操作'
        (providerTh({provider}) for provider in providers)...
      ]
    ]
    html.tbody {},
      for attr, index in [attrs..., newAttr]
        attrTr({attr, index, providers: providers})
  ]

node = document.getElementById('admin_attrs')

app {init, view, node}



