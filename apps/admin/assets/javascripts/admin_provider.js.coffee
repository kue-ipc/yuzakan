# プロバイダー

import {text, app} from '../hyperapp.js?v=6.0.0'
import {div, span, label, input, select, option, button, br} from '../hyperapp-html.js?v=0.6.0'
import {fetchJsonGet} from '../fetch_json.js?v=0.6.0'
import {fieldName, fieldId} from '../form_helper.js?v=0.6.0'
import providerParams from './provider_params.js?v=0.6.0'

abilities = [
  {name: 'readable', label: '読み取り'}
  {name: 'writable', label: '書き込み'}
  {name: 'authenticatable', label: '認証'}
  {name: 'password_changeable', label: 'パスワード変更'}
  {name: 'lockable', label: 'ロック'}
]

parentNames = ['provider']

providerParamAction = (state, {name, value}) ->
  {state..., provider: {state.provider..., params: {state.provider.params..., [name]: value}}}

providerAction = (state, {provider}) ->
  newState = {state..., provider: {state.provider..., provider...}}
  return newState unless provider.adapter_name?

  for adapter in state.adapters when adapter.name == provider.adapter_name
    return newState if adapter.param_types?
    break

  [
    newState
    [showAdapterRunner, {name: provider.adapter_name}]
  ]

adapterAction = (state, {name, adapter}) ->
  name ?= adapter.name
  adapters = for current in state.adapters
    if current.name == adapter.name
      {current..., adapter...}
    else
      current
  {state..., adapters}


showAdapterRunner = (dispatch, {name}) ->
  return unless name?

  response = await fetchJsonGet({url: "/api/adapters/#{name}"})
  if response.ok
    dispatch(adapterAction, {name: name, adapter: response.data})
  else
    console.log respons

showProviderRunner = (dispatch, {name}) ->
  return unless name?

  response = await fetchJsonGet({url: "/api/providers/#{name}"})
  if response.ok
    dispatch(providerAction, {provider: response.data})
  else
    console.log respons

initAllAdaptersAction = (state, {adapters}) ->
  {state..., adapters}

indexAllAdaptersRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/adapters'})
  if response.ok
    dispatch(initAllAdaptersAction, {adapters: response.data})
  else
    console.error response

name = location.pathname.split('/').at(-1)
name = undefined if name == '*'

init = [
  {name, provider: {params: {}}, adapters: []}
  [indexAllAdaptersRunner]
  [showProviderRunner, {name}]
]

view = ({name, provider, adapters}) ->
  provider_adapter = (adapter for adapter in adapters when adapter.name == provider.adapter_name)[0]
  div {}, [
    div {class: 'mb-3'}, [
      label {class: 'form-label', for: 'provider-name'}, text '名前'
      input {
        id: 'provider-name', class: 'form-control', type: 'text', required: true, value: provider.name
        oninput: (state, event) -> [providerAction, {provider: {name: event.target.value}}]
      }
    ]
    div {class: 'mb-3'}, [
      label {class: 'form-label', for: 'provider-label'}, text '表示名'
      input {
        id: 'provider-label', class: 'form-control', type: 'text', required: true, value: provider.label
        oninput: (state, event) -> [providerAction, {provider: {label: event.target.value}}]
      }
    ]
    div {}, [
      label {class: 'form-label'}, text '可能な操作'
      br {}
      (abilities.map (ability) ->
        div {class: 'form-check form-check-inline'}, [
          input {
            id: "provider-#{ability.name}", class: 'form-check-input', type: 'checkbox'
            checked: provider[ability.name]
            onchange: (state, event) -> [providerAction, {provider: {[ability.name]: !provider[ability.name]}}]
          }
          label {class: 'form-check-label', for: "provider-#{ability.name}"}, text ability.label
        ]
      )...
    ]
    div {class: 'form-check'}, [
      input {
        id: "provider-individual_password", class: 'form-check-input', type: 'checkbox'
        checked: provider.individual_password
        onchange: (state, event) -> [providerAction, {provider: {individual_password: !provider.individual_password}}]
      }
      label {class: 'form-check-label', for: "provider-individual_password"}, text 'パスワード個別設定'
      span {class: 'ms-1 form-text'}, text '複数プロバイダー一括でのパスワード変更やリセットの対象になりません。'
    ]
    div {class: 'form-check'}, [
      input {
        id: "provider-self_management", class: 'form-check-input', type: 'checkbox'
        checked: provider.self_management
        onchange: (state, event) -> [providerAction, {provider: {self_management: !provider.self_management}}]
      }
      label {class: 'form-check-label', for: "provider-self_management"}, text '自己管理可能'
      span {class: 'ms-1 form-text'}, text 'ユーザー自身が登録やパスワードリセット等ができるようになります。'
    ]
    div {class: 'mb-3'}, [
      label {class: 'form-label', for: 'provider-adapter_name'}, text 'アダプター'
      select {
        id: 'provider-adapter_name', class: 'form-control'
        oninput: (state, event) -> [providerAction, {provider: {adapter_name: event.target.value}}]
      },
        if provider.adapter_name?
          for adapter in adapters
            option {value: adapter.name, selected: adapter.name == provider.adapter_name}, text adapter.label
        else
          [
            option {selected: true}, text '選択してください。'
            (for adapter in adapters
              option {value: adapter.name, selected: adapter.name == provider.adapter_name}, text adapter.label
            )...
          ]
    ]
    providerParams {
      params: provider.params
      param_types: provider_adapter?.param_types ? []
      action: providerParamAction
    }
    div {class: 'mb-1'},
      if !name?
        [
          button {
            class: 'btn btn-primary'
            onclick: (state) -> [state, [createProviderRunner, {provider}]]
          }, text '作成'
        ]
      else if provider.immutable == false
        [
          button {
            class: 'btn btn-warning'
            onclick: (state) -> [state, [updateProviderRunner, {provider}]]
          }, text '更新'
          button {
            class: 'ms-1 btn btn-danger'
            onclick: (state) -> [state, [destroyProviderRunner, {provider}]]
          }, text '削除'
        ]
  ]

node = document.getElementById('admin_provider')

app {init, view, node}
