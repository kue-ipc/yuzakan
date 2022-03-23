import {h, text, app} from '../hyperapp.js?v=6.0.0'
import {div, span, label, input, select, option, button, br} from '../hyperapp-html.js?v=0.6.0'
import {fetchJsonGet} from '../fetch_json.js?v=0.6.0'

abilities = [
  {name: 'readable', label: '読み取り'}
  {name: 'writable', label: '書き込み'}
  {name: 'authenticatable', label: '認証'}
  {name: 'password_changeable', label: 'パスワード変更'}
  {name: 'lockable', label: 'ロック'}
]


providerAction = (state, {provider}) ->
  {state..., provider: {state.provider..., provider...}}

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
  {name, provider: {}, adapters: []}
  [indexAllAdaptersRunner]
  [showProviderRunner, {name}]
]

view = ({name, provider, adapters}) ->
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
        for adapter in adapters
          option {value: adapter.name, selected: adapter.name == provider.adapter_name}, text adapter.label
    ]

    # providerParams()

    div {class: 'mb-1'},
      if provider.immutable
        []
      else if name?
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
      else
        [
          button {
            class: 'btn btn-primary'
            onclick: (state) -> [state, [createProviderRunner, {provider}]]
          }, text '作成'
        ]
  ]

node = document.getElementById('admin_provider')

app {init, view, node}
