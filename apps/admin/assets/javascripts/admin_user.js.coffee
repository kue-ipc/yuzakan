# ユーザー

import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'
import {fetchJsonGet} from '../fetch_json.js'
import {fieldName, fieldId} from '../form_helper.js'
import WebData from '../web_data.js'
import ConfirmDialog from '../confirm_dialog.js'
import csrf from '../csrf.js'

import {toRomaji, toKatakana, toHiragana} from '../ja_conv.js'
import {capitalize} from '../string_utils.js'

clearanceLevels = [
  {name: 'supervisor', value: 5, label: '特権管理者'}
  {name: 'administrator', value: 4, label: '管理者'}
  {name: 'operator', value: 3, label: '操作者'}
  {name: 'monitor', value: 2, label: '監視者'}
  {name: 'user', value: 1, label: '一般ユーザー'}
  {name: 'guest', value: 0, label: 'ゲスト'}
]

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

  func = new Function('{name, display_name, email, attrs, tools}', code)
  try
    result = func {
      name: userdata.name
      username: userdata.name
      display_name: userdata.display_name
      email: userdata.email
      attrs: {userdata.attrs...}
      tools: {toRomaji, toKatakana, toHiragana, capitalize}
    }
  catch error
    console.warn(func)
    console.warn(error)
    return

  result

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

view = ({mode, name, user, providers, attrs}) ->
  provider_userdatas =
    for provider in providers
      (user.userdata_list.find (data) -> data.provider.name == provider.name)?.userdata

  html.div {}, [
    html.h4 {}, text '基本情報'
    html.dl {class: 'row'}, [
      html.dt {class: 'col-sm-4 col-md-3 col-lg-2'},
        html.label {class: 'form-label', for: 'user-name'}, text 'ユーザー名'
      html.dd {class: 'col-sm-8 col-md-9 col-lg-10'},
        if mode == 'show'
          text user.name
        else
          html.input {
            id: 'user-name'
            class: if mode == 'show' then 'form-control-plaintext' else 'form-control'
            type: 'text'
            required: true
            value: user.name
            oninput: (state, event) -> [userAction, {user: {name: event.target.value}}]
          }
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
          text (clearanceLevels.find (level) -> level.value == user.clearance_level).label
        else
          html.select {
            class: 'form-select'
            oninput: (state, event) ->
              [userAction, {user: {clearance_level: parseInt(event.target.value, 10)}}]
          },
            for level in clearanceLevels
              html.option {
                value: level.value
                selected: level.value == user.clearance_level
              }, text level.label
    ]

    html.h4 {}, text '操作メニュー'
    html.div {}, [
      html.div {}, text 'パスワードリセット'
      html.div {}, text 'ロック'
      html.div {}, text '更新'
      html.div {}, text '削除'
    ]

    html.h4 {}, text '登録状況'

    html.table {class: 'table'}, [
      html.thead {},
        html.tr {}, [
          html.th {}, text '名前'
          html.th {}, text '値'
          (html.th({}, text provider.label) for provider in providers)...
        ]
      html.tbody {},
        for {name, label} in [
          {name: 'name', label: 'ユーザー名'}
          {name: 'display_name', label: '表示名'}
          {name: 'email', label: 'メールアドレス'}
          {name: 'locked', label: 'ロック'}
          {name: 'disabled', label: '無効'}
          {name: 'unmanageable', label: '管理不可'}
          {name: 'mfa', label: '多要素'}
        ]
          html.tr {}, [
            html.td {}, text label
            html.td {}, text user[name] ? ''
            (
              for userdata in provider_userdatas
                html.td {},
                  if not userdata?[name]
                    html.span {class: 'text-muted'}, text 'N/A'
                  else if user[name] == userdata[name]
                    html.span {class: 'text-success'}, text userdata?[name]
                  else
                    html.span {class: 'text-danger'}, text userdata?[name]
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
            html.td {}, text defaultValue ? ''
            html.td {},
              if not defaultValue?
                html.span {}, text value ? ''
              else if defaultValue != value
                html.span {class: 'text-danger'}, text value ? ''
              else
                html.span {class: 'text-success'}, text value ? ''
            (
              for userdata in provider_userdatas
                html.td {},
                  if not userdata?.attrs?[attr.name]
                    html.span {class: 'text-muted'}, text 'N/A'
                  else if value == userdata.attrs[attr.name]
                    html.span {class: 'text-success'}, text userdata.attrs[attr.name]
                  else
                    html.span {class: 'text-danger'}, text userdata.attrs[attr.name]
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
