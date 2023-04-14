import {text} from '~/vendor/hyperapp.js'
import * as html from '~/vendor/hyperapp-html.js'

import {entityLabel} from '~/common/helper.js'

import bsIcon from '~/app/bs_icon.js'
import valueDisplay from '~/app/value_display.js'

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
        bsIcon({name: 'check-square'})
    else
      html.span {class: "text-muted"},
        bsIcon({name: 'square'})

providerTd = ({user, provider, name, type}) ->
  return html.td {} unless user.providers.includes(provider.name)

  data = user.providers_data.get(provider.name)

  html.td {},
    valueDisplay {
      value: data?[name]
      type
      color:
        if user[name]
          if user[name] == data?[name]
            'success'
          else
            'danger'
        else
          'body'
    }

providerTr = ({user, providers, name, label, type}) ->
  html.tr {}, [
    html.th {}, text label
    (providerTd {user, provider, name, type} for provider in providers)...
  ]

providerCheckTd = ({mode, user, provider}) ->
  html.td {},
    providerCheck {
      provider_name: provider.name
      checked: user.providers.includes(provider.name)
      edit: mode != 'show'
    }

export default userProvider = ({mode, user, providers}) ->
  html.div {}, [
    html.h4 {}, text 'プロバイダー登録状況'
    html.table {class: 'table'}, [
      html.thead {},
        html.tr {}, [
          html.th {}, text ''
          (html.th({}, text entityLabel(provider)) for provider in providers)...
        ]
      html.tbody {}, [
        html.tr {}, [
          html.th {}, text '登録'
          (providerCheckTd({mode, user, provider}) for provider in providers)...
        ]
        (if mode != 'new' then (providerTr {user, providers, item...} for item in PROVIDER_REG_ITEMS) else [])...
      ]
    ]
  ]
