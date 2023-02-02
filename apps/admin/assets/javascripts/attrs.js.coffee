import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import csrf from '/assets/csrf.js'
import ConfirmDialog from '/assets/confirm_dialog.js'
import InputTextDialog from '/assets/input_text_dialog.js'
import {ATTR_TYPES, MAPPING_CONVERSIONS} from '/assets/definition.js'

import {fetchJsonGet, fetchJsonPost, fetchJsonPatch, fetchJsonDelete} from '/assets/api/fetch_json.js'
import {runGetProviders} from '/assets/api/providers.js'
import {createRunGetAttrs} from '/assets/api/attrs.js'

deleteConfirm = new ConfirmDialog {
  id: 'attrs_confirm'
  status: 'alert'
  title: '属性の削除'
  message: '属性を削除してもよろしいですか？'
  action: {
    color: 'danger'
    label: '削除'
  }
}

inputCode = new InputTextDialog {
  id: 'attrs_input_code'
  title: 'コードの入力'
  size: 4096
}

providerTh = ({provider}) ->
  html.th {}, text provider.label

attrMappingTd = ({attr, provider}) ->
  unless attr.mappings?
    return html.td {}, text '読み込み中'

  mapping = attr.mappings.find (mapping) ->
    mapping.provider == provider.name
  mapping ?= {name: '', conversion: null}

  html.td {}, [
    html.input {
      class: 'form-control mb-1'
      type: 'text'
      value: mapping.name
      oninput: (state, event) -> [
        attrMappingAction
        {name: attr.name, mapping: {name: event.target.value, provider: provider.name}}
      ]
    }
    html.select {
      class: 'form-select'
      oninput: (state, event) -> [
        attrMappingAction
        {name: attr.name, mapping: {conversion: event.target.value, provider: provider.name}}
      ]
      }, MAPPING_CONVERSIONS.map (conversion) ->
        html.option {
          value: conversion.value
          selected: conversion.value == mapping.conversion
        }, text conversion.label
  ]

attrTr = ({attr, index, providers}) ->
  html.tr {}, [
    html.td {},
      if attr.order?
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
        class: 'form-select mb-1'
        onchange: (state, event) -> [attrAction, {name: attr.name, attr: {type: event.target.value}}]
      }, ATTR_TYPES.map (attrType) ->
        html.option {
          value: attrType.value
          selected: attrType.value == attr.type
        }, text attrType.label

      html.div {class: 'btn-group', role: 'group'}, [
        html.input {
          id: "#{attr.name}-hidden-check"
          class: 'btn-check'
          type: 'checkbox'
          autocomplete: 'off'
          checked: attr.hidden
          onchange: (state, event) -> [attrAction, {name: attr.name, attr: {hidden: !attr.hidden}}]
        }

        html.label {
          class:
            if attr.hidden
              'btn btn-primary'
            else
              'btn btn-outline-primary'
          for: "#{attr.name}-hidden-check"
        }, text '隠し'

        html.input {
          id: "#{attr.name}-readonly-check"
          class: 'btn-check'
          type: 'checkbox'
          autocomplete: 'off'
          checked: attr.readonly
          onchange: (state, event) -> [attrAction, {name: attr.name, attr: {readonly: !attr.readonly}}]
        }

        html.label {
          class:
            if attr.readonly
              'btn btn-primary'
            else
              'btn btn-outline-primary'
          for: "#{attr.name}-readonly-check"
        }, text '読取専用'

        html.button {
          class: if attr.code then 'btn btn-primary' else 'btn btn-outline-primary'
          onclick: (state) -> [state, [inputCodeRunner, {attr}]]
        }, text 'コード'
      ]
    ]
    html.td {},
      if attr.order?
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

replaceAttrMapping = (mappings, mapping) ->
  replaced = false
  new_attr_mappings = for current in mappings
    if current.provider == mapping.provider
      replaced = true
      {current..., mapping...}
    else
      current

  if replaced
    new_attr_mappings
  else
    [new_attr_mappings..., {name: '', conversion: null, mapping...}]

attrMappingAction = (state, {name, mapping}) ->
  if name
    attrs = for attr in state.attrs
      if attr.name == name
        {attr..., mappings: replaceAttrMapping(attr.mappings, mapping)}
      else
        attr
    {state..., attrs}
  else
    {
      state...
      newAttr: {state.newAttr..., mappings: replaceAttrMapping(state.newAttr.mappings, mapping)}
    }

inputCodeRunner = (dispatch, {attr}) ->
  code = await inputCode.inputPromise {
    messages: ["#{attr.name} のデフォルト値を生成するJavaScriptのコードを入力してください。"]
    value: attr.code ? ''
  }
  if code?
    if code
      dispatch(attrAction, {name: attr.name, attr: {code}})
    else
      dispatch(attrAction, {name: attr.name, attr: {code: null}})

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
  confirm = await deleteConfirm.showPromise({messages: ["属性「#{attr.name}」を削除してもよろしいですか？"]})
  if confirm
    response = await fetchJsonDelete({url: "/api/attrs/#{attr.name}", data: csrf()})
    if response.ok
      dispatch(deleteAttrAction, {name: attr.name})
    else
      console.error response

upAttrAction = (state, {name}) ->
  attrIndex = state.attrs.findIndex (attr) -> attr.name == name
  newOrder =
    switch attrIndex
      when 0, 1
        state.attrs[0].order - 8
      else
        Math.floor((state.attrs[attrIndex - 1].order + state.attrs[attrIndex - 2].order) / 2)

  if state.attrs[attrIndex].order == newOrder
    console.warn '移動できません。'
    return state
 
  newAttr = {state.attrs[attrIndex]..., order: newOrder}

  [
    {
      state...
      attrs: [
        state.attrs[...(attrIndex)]...
        state.attrs[(attrIndex + 1)..]...
        newAttr
      ].sort (a, b) -> a.order - b.order || a.name.localeCompare(b.name)
    }
    [updateAttrRunner, {attr: newAttr}]
  ]

downAttrAction = (state, {name}) ->
  attrIndex = state.attrs.findIndex (attr) -> attr.name == name
  newOrder =
    switch attrIndex
      when state.attrs.length - 1, state.attrs.length - 2
        state.attrs.at(-1).order + 8
      else
        Math.floor((state.attrs[attrIndex + 1].order + state.attrs[attrIndex + 2].order) / 2)

  if state.attrs[attrIndex].order == newOrder
    console.warn '移動できません。'
    return state
 
  newAttr = {state.attrs[attrIndex]..., order: newOrder}

  [
    {
      state...
      attrs: [
        state.attrs[...(attrIndex)]...
        state.attrs[(attrIndex + 1)..]...
        newAttr
      ].sort (a, b) -> a.order - b.order || a.name.localeCompare(b.name)
    }
    [updateAttrRunner, {attr: newAttr}]
  ]

showAttrRunner = (dispatch, {attr}) ->
  response = await fetchJsonGet({url: "/api/attrs/#{attr.name}"})
  if response.ok
    dispatch(attrAction, {attr: response.data})
  else
    console.error response

SetAttrsThenShow = (state, attrs) ->
  [
    {state..., attrs}
    ([showAttrRunner, {attr}] for attr in attrs)...
  ]

runGetAttrsThenShow = createRunGetAttrs(SetAttrsThenShow)

initNewAttr = {
  name: undefined
  newName: ''
  label: ''
  type: 'string'
  hidden: false
  mappings: []
}

init = [
  {
    attrs: []
    providers: []
    newAttr: initNewAttr
  }
  [runGetAttrsThenShow]
  [runGetProviders]
]

view = ({attrs, providers, newAttr}) ->
  html.table {class: 'table'}, [
    html.thead {}, [
      html.tr {}, [
        html.th {}, text '順番'
        html.th {}, text '名前/表示名'
        html.th {}, text '型/オプション'
        html.th {}, text '操作'
        (providerTh({provider}) for provider in providers)...
      ]
    ]
    html.tbody {},
      for attr, index in [attrs..., newAttr]
        attrTr({attr, index, providers: providers})
  ]

node = document.getElementById('attrs')

app {init, view, node}



