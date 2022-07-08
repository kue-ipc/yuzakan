# /admin/user/*

import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'
import {fetchJsonGet} from '../fetch_json.js'
import {fieldName, fieldId} from '../form_helper.js'
import WebData from '../web_data.js'
import ConfirmDialog from '../confirm_dialog.js'
import csrf from '../csrf.js'
import BsIcon from '../bs_icon.js'
import {toRomaji, toKatakana, toHiragana} from '../ja_conv.js'
import {capitalize} from '../string_utils.js'
import {xxh32, xxh64} from '../hash.js'
import {CLEARANCE_LEVELS} from '../definition.js'

parentNames = ['user']

destroyConfirm = new ConfirmDialog {
  id: fieldId('destroy', ['modal', 'confirm', parentNames...])
  status: 'alert'
  title: 'ユーザーの削除'
  message: 'ユーザーを削除してもよろしいですか？'
  action: {
    color: 'danger'
    label: '削除'
  }
}

createWebData = new WebData {
  id: fieldId('create', ['modal', 'web', parentNames...])
  title: 'ユーザーの作成'
  method: 'POST'
  url: '/api/users'
  codeActions: new Map [
    [201, {status: 'success', message: 'ユーザーを作成しました。'}]
  ]
}

updateWebData = new WebData {
  id: fieldId('update', ['modal', 'web', parentNames...])
  title: 'ユーザーの更新'
  method: 'PATCH'
  codeActions: new Map [
    [200, {status: 'success', message: 'ユーザーを更新しました。'}]
  ]
}

destroyWebData = new WebData {
  id: fieldId('destroy', ['modal', 'web', parentNames...])
  title: 'ユーザーの削除'
  method: 'DELETE'
  codeActions: new Map [
    [200, {status: 'success', message: 'ユーザーを削除しました。', redirectTo: '/admin/users', reloadTime: 10}]
  ]
}

getAttrDefaultValue = ({userdata, attr}) ->
  return unless attr.code

  code =
    if /\breturn\b/.test(attr.code)
      attr.code
    else
      "return #{attr.code};"

  func = new Function('{name, username, display_name, email, attrs, tools}', code)
  try
    result = func {
      name: userdata.name
      username: userdata.name
      display_name: userdata.display_name
      email: userdata.email
      attrs: {userdata.attrs...}
      tools: {toRomaji, toKatakana, toHiragana, capitalize, xxh32, xxh64}
    }
  catch error
    console.warn({msg: 'Failed to getAttrDefaultValue', code: code, error: error})
    return

  result

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


valueNode = ({value, name = null, type = 'string', edit = false, color = 'body'}) ->
  return html.span {class: 'text-muted'}, text 'N/A' unless value? || edit

  switch type
    when 'string'
      if edit
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'text'
          value
          oninput: (state, event) -> [userValueAction, {name, value: event.target.value}]
        }
      else
        html.span {class: "text-#{color}"}, text value
    when 'boolean'
      if edit
        html.div {class: 'form-check'},
          html.input {
            id: "value-#{name}"
            class: 'form-check-input'
            type: 'checkbox'
            checked: value
            onchange: (state, event) -> [userValueAction, {name, value: !value}]
          }
      else
        html.span {class: "text-#{color}"},
          if value
            BsIcon({name: 'check-square'})
          else
            BsIcon({name: 'square'})
    when 'integer'
      if edit
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'number'
          value
          oninput: (state, event) -> [userValueAction, {name, value: parseInt(event.target.value)}]
        }
      else
        html.span {class: "text-#{color}"}, text value
    when 'float'
      if edit
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'number'
          value
          step: '0.001'
          oninput: (state, event) -> [userValueAction, {name, value: Number(event.target.value)}]
        }
      else
        html.span {class: "text-#{color}"}, text value
    when 'datetime'
      if edit
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'datetime'
          value
          oninput: (state, event) -> [userValueAction, {name, value: Date(event.target.value)}]
        }
      else
        html.span {class: "text-#{color}"}, text value
    when 'date'
      if edit
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'date'
          value
          oninput: (state, event) -> [userValueAction, {name, value: Date(event.target.value)}]
        }
      else
        html.span {class: "text-#{color}"}, text value
    when 'time'
      if edit
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'time'
          value
          oninput: (state, event) -> [userValueAction, {name, value: Date(event.target.value)}]
        }
      else
        html.span {class: "text-#{color}"}, text value
    when 'list'
      html.span {class: "text-#{color}"}, text value.join(' ')

userValueAction = (state, {name, value}) ->
  throw new Error('No name value aciton') unless name?

  names = name.split('.')
  if names.length = 1
    {
      state...
      user: {
        state.user...
        [names[0]]: value
      }
    }
  else if names.length = 2
    {
      state...
      user: {
        state.user...
        [names[0]]: {
          state.user[names[0]]...
          [names[1]]: value
        }
      }
    }
  else if names.length = 2
    {
      state...
      user: {
        state.user...
        [names[0]]: {
          state.user[names[0]]...
          [names[1]]: {
            state.user[names[0]][names[1]]...
            [names[2]]: value
          }
        }
      }
    }
  else
    throw new Error("Deep name: #{name}")

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


userAction = (state, {name, user}) ->
  history.pushState(null, null, "/admin/users/#{name}") if name? && name != state.name

  {
    state...
    name: name ? state.name
    user: {state.user..., user...}
  }

createUserRunner = (dispatch, {user}) ->
  response = await createWebData.submitPromise {data: {csrf()..., user...}}
  if response.ok
    user = response.data
    dispatch(userAction, {name: user.name, user})
  else
    console.error response

updateUserRunner = (dispatch, {name, user}) ->
  response = await updateWebData.submitPromise {url: "/api/users/#{name}", data: {csrf()..., user...}}
  if response.ok
    user = response.data
    dispatch(userAction, {name: user.name, user})
  else
    console.error response

destroyUserRunner = (dispatch, {name}) ->
  confirm = await destroyConfirm.confirmPromise({message: "属性「#{name}」を削除してもよろしいですか？"})
  if confirm
    response = await destroyWebData.submitPromise {url: "/api/users/#{name}", data: csrf()}
    if response.ok
      # redirect...
    else
      console.error response

showUserRunner = (dispatch, {name}) ->
  return unless name?

  response = await fetchJsonGet({url: "/api/users/#{name}"})
  if response.ok
    dispatch(userAction, {user: response.data})
  else
    console.error respons

initAllProvidersAction = (state, {providers}) ->
  {state..., providers}

indexAllProvidersRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/providers'})
  if response.ok
    dispatch(initAllProvidersAction, {providers: response.data})
  else
    console.error response

initAllAttrsAction = (state, {attrs}) ->
  {state..., attrs}

indexAllAttrsRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/attrs'})
  if response.ok
    dispatch(initAllAttrsAction, {attrs: response.data})
  else
    console.error response

name = location.pathname.split('/').at(-1)
name = undefined if name == '*'
mode = if name? then 'show' else 'new'

initUser = {
  name: ''
  clearance_level: 1
  userdata: {attrs: {}}
  userdata_list: []
}

init = [
  {mode, name, user: initUser, providers: [], attrs: []}
  [indexAllProvidersRunner]
  [indexAllAttrsRunner]
  [showUserRunner, {name}]
]

view = ({mode, name, user, providers, attrs, edit}) ->
  provider_userdatas =
    for provider in providers
      (user.userdata_list.find (data) -> data.provider.name == provider.name)?.userdata

  html.div {}, [
    html.h4 {}, text '基本情報'
    html.dl {class: 'row'}, [
      html.dt {class: 'col-sm-4 col-md-3 col-lg-2'},
        html.label {class: 'form-label', for: 'user-name'}, text 'ユーザー名'
      html.dd {class: 'col-sm-8 col-md-9 col-lg-10'},
        switch mode
          when 'new'
            html.input {
              id: 'user-name'
              class: 'form-control'
              type: 'text'
              required: true
              value: user.name
              oninput: (state, event) -> [userAction, {user: {name: event.target.value}}]
            }
          when 'edit'
            html.input {
              id: 'user-name'
              class: 'form-control-plaintext'
              readonly: true
              type: 'text'
              value: user.name
            }
          when 'show'
            text user.name
      html.dt {class: 'col-sm-4 col-md-3 col-lg-2'},
        text '表示名'
      html.dd {class: 'col-sm-8 col-md-9 col-lg-10'},
        if mode == 'new'
          html.span {class: 'text-muted'}, text '(属性値にて設定)'
        else
          text user.display_name ? ''
      html.dt {class: 'col-sm-4 col-md-3 col-lg-2'},
        text 'メールアドレス'
      html.dd {class: 'col-sm-8 col-md-9 col-lg-10'},
        if mode == 'new'
          html.span {class: 'text-muted'}, text '(属性値にて設定)'
        else
          text user.email ? ''
      html.dt {class: 'col-sm-4 col-md-3 col-lg-2'},
        text '権限レベル'
      html.dd {class: 'col-sm-8 col-md-9 col-lg-10'},
        if mode == 'show'
          text (CLEARANCE_LEVELS.find (level) -> level.value == user.clearance_level).label
        else
          html.select {
            class: 'form-select'
            oninput: (state, event) ->
              [userAction, {user: {clearance_level: parseInt(event.target.value, 10)}}]
          },
            for level in CLEARANCE_LEVELS
              html.option {
                value: level.value
                selected: level.value == user.clearance_level
              }, text level.label
    ]

    html.h4 {}, text '操作メニュー'
    html.div {}, [
      html.div {}, text 'パスワードリセット'
      html.div {}, text 'ロック'
    ]

    html.h4 {}, text '内容'

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
        (
          for {name, label, type} in [
            {name: 'name', label: 'ユーザー名', type: 'string'}
            {name: 'display_name', label: '表示名', type: 'string'}
            {name: 'email', label: 'メールアドレス', type: 'string'}
            {name: 'groups', label: 'グループ', type: 'list'}
            {name: 'locked', label: 'ロック', type: 'boolean'}
            {name: 'disabled', label: '無効', type: 'boolean'}
            {name: 'unmanageable', label: '管理不可', type: 'boolean'}
            {name: 'mfa', label: '多要素', type: 'boolean'}
          ]
            html.tr {}, [
              html.td {}, text label
              html.td {},
                valueNode {
                  value: user.userdata[name]
                  type
                }
              (
                for userdata in provider_userdatas
                  html.td {},
                    valueNode {
                      value: userdata?[name]
                      type
                      color:
                        if type == 'list'
                          'body'
                        else if user.userdata[name] == userdata?[name]
                          'success'
                        else
                          'danger'
                    }
              )...
            ]
        )...
      ]
    ]

    html.h4 {}, text '属性'

    html.table {class: 'table'}, [
      html.thead {},
        html.tr {}, [
          html.th {}, text '属性名'
          html.th {}, text 'デフォルト値'
          html.th {}, text '設定値'
          (html.th({}, text provider.label) for provider in providers)...
        ]
      html.tbody {},
        for attr in attrs
          defaultValue = getAttrDefaultValue({userdata: user.userdata, attr})
          value = user.userdata.attrs[attr.name]

          html.tr {}, [
            html.td {}, text attr.label
            html.td {},
              valueNode {value: defaultValue, type: attr.type}

            html.td {},
              valueNode {
                value: value
                type: attr.type
                edit: mode != 'show'
                color:
                  if not defaultValue?
                    'default'
                  else if defaultValue == value
                    'success'
                  else
                    'danger'
              }

            (
              for userdata in provider_userdatas
                html.td {},
                  valueNode {
                    value: userdata?.attrs?[attr.name]
                    type: attr.type
                    color:
                      if value == userdata?.attrs?[attr.name]
                        'success'
                      else
                        'danger'
                  }
            )...
          ]
    ]
    html.div {class: 'mb-1'},
      if name?
        [
          html.div {class: 'form-check form-switch'}, [
            html.input {
              id: 'user-mode-edit'
              class: 'form-check-input'
              type: 'checkbox'
              role: 'switch'
              checked: mode != 'show'
              onchange: (state, event) -> {state..., mode: if mode == 'show' then 'edit' else 'show'}
            }
            html.label {
              class: 'form-check-label'
              for: 'user-mode-edit'
            }, text '編集モード'
          ]
          if mode != 'show'
            html.div {}, [
              html.button {
                class: 'btn btn-warning'
                onclick: (state) -> [state, [updateUserRunner, {name, user}]]
              }, text '更新'
              html.button {
                class: 'ms-1 btn btn-danger'
                onclick: (state) -> [state, [destroyUserRunner, {name}]]
              }, text '削除'
            ]
        ]
      else
        [
          html.button {
            class: 'btn btn-primary'
            onclick: (state) -> [state, [createUserRunner, {user}]]
          }, text '作成'
        ]
  ]


node = document.getElementById('admin_user')

app {init, view, node}
