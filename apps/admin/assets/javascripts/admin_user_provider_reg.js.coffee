import {text} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

import valueDisplay from '../value_display.js'

PROVIDER_REG_ITEMS = [
  {name: 'name', label: 'ユーザー名', type: 'string'}
  {name: 'display_name', label: '表示名', type: 'string'}
  {name: 'email', label: 'メールアドレス', type: 'string'}
  {name: 'locked', label: 'ロック', type: 'boolean'}
  {name: 'disabled', label: '無効', type: 'boolean'}
  {name: 'unmanageable', label: '管理不可', type: 'boolean'}
  {name: 'mfa', label: '多要素', type: 'boolean'}
]

userAddProviderAction = (state, {provider_name}) ->
  if state.user.userdata_list.some (data) -> data.provider.name == provider_name
    state
  else
    {
      state...
      user: {
        state.user...
        userdata_list: [state.user.userdata_list..., {provider: {name: provider_name}}]
      }
    }

userRemoveProviderAction = (state, {provider_name}) ->
  console.log provider_name
  {
    state...
    user: {
      state.user...
      userdata_list: state.user.userdata_list.filter (data) -> data.provider.name != provider_name
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
  provider_userdata = (user.userdata_list.find (data) -> data.provider.name == provider.name)

  html.td {},
    valueDisplay {
      value: provider_userdata?.userdata?[name]
      type
      color:
        if type == 'list'
          'body'
        else if user.userdata[name] == provider_userdata?[name]
          'success'
        else
          'danger'
    }


providerRegTr = ({user, providers, name, label, type}) ->
  html.tr {}, [
    html.td {}, text label
    html.td {}, valueDisplay {value: user.userdata[name], type}
    (providerRegProviderTd {user, provider, name, type} for provider in providers)...
  ]

export default providerReg = ({mode, user, providers}) ->
  html.div {}, [
    html.h4 {}, text 'プロバイダー登録状況'
    html.table {class: 'table'}, [
      html.thead {},
        html.tr {}, [
          html.th {}, text '名前'
          html.th {}, text '値'
          (html.th({}, text provider.label) for provider in providers)...
        ]
      html.tbody {}, [
        html.tr {}, [
          html.td {}, text 'プロバイダー'
          html.td {}, text ''
          (
            for provider in providers
              found_provider = (user.userdata_list.find (data) -> data.provider.name == provider.name)
              html.td {},
                providerCheck {provider_name: provider.name, checked: found_provider?, edit: mode != 'show'}
          )...
        ]
        (providerRegTr {user, providers, item...} for item in PROVIDER_REG_ITEMS)...
      ]
    ]
  ]
