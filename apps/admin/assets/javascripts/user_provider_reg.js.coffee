import {text} from '/assets/hyperapp.js'
import * as html from '/assets/hyperapp-html.js'

import BsIcon from '/assets/bs_icon.js'
import valueDisplay from '/assets/value_display.js'

PROVIDER_REG_ITEMS = [
  {name: 'username', label: 'ユーザー名', type: 'string'}
  {name: 'display_name', label: '表示名', type: 'string'}
  {name: 'email', label: 'メールアドレス', type: 'string'}
  {name: 'locked', label: 'ロック', type: 'boolean'}
  {name: 'unmanageable', label: '管理不可', type: 'boolean'}
  {name: 'mfa', label: '多要素', type: 'boolean'}
]

userAddProviderAction = (state, {provider_name}) ->
  if state.user.providers.includes(provider_name)
    state
  else
    {
      state...
      user: {
        state.user...
        providers: [state.user.providers..., provider_name]
      }
    }

userRemoveProviderAction = (state, {provider_name}) ->
  {
    state...
    user: {
      state.user...
      providers: state.user.providers.filter (item) -> item != provider_name
    }
  }

providerCheck = ({provider_name, checked, edit = false}) ->
  if edit
    html.div {class: 'form-check'},
      html.input {
        id: "provider-#{provider_name}"
        class: 'form-check-input'
        type: 'checkbox'
        checked
        onchange:
          if checked
            [userRemoveProviderAction, {provider_name}]
          else
            [userAddProviderAction, {provider_name}]
      }
  else
    if checked
      html.span {class: "text-success"},
        BsIcon({name: 'check-square'})
    else
      html.span {class: "text-muted"},
        BsIcon({name: 'square'})

providerRegProviderTd = ({user, provider, name, type}) ->
  return html.td {} unless user.providers.includes(provider.name)

  provider_userdata = (user.provider_userdatas.find (data) -> data.provider.name == provider.name)

  html.td {},
    valueDisplay {
      value: provider_userdata?.userdata?[name]
      type
      color:
        if user[name]
          if user[name] == provider_userdata?.userdata?[name]
            'success'
          else
            'danger'
        else
          'body'
    }

providerRegTr = ({user, providers, name, label, type}) ->
  html.tr {}, [
    html.th {}, text label
    # html.td {}, valueDisplay {value: user.userdata[name], type}
    (providerRegProviderTd {user, provider, name, type} for provider in providers)...
  ]

providerCheckTd = ({mode, user, provider}) ->
  html.td {},
    providerCheck {
      provider_name: provider.name
      checked: user.providers.includes(provider.name)
      edit: mode != 'show'
    }

export default providerReg = ({mode, user, providers}) ->
  html.div {}, [
    html.h4 {}, text 'プロバイダー登録状況'
    html.table {class: 'table'}, [
      html.thead {},
        html.tr {}, [
          html.th {}, text ''
          (html.th({}, text provider.label) for provider in providers)...
        ]
      html.tbody {}, [
        html.tr {}, [
          html.th {}, text '登録'
          (providerCheckTd({mode, user, provider}) for provider in providers)...
        ]
        (if mode != 'new' then (providerRegTr {user, providers, item...} for item in PROVIDER_REG_ITEMS) else [])...
      ]
    ]
  ]
