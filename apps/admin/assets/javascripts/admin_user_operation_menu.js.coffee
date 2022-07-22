import {text} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'
import {DateTime} from '../luxon.js'

import {fieldName, fieldId} from '../form_helper.js'
import csrf from '../csrf.js'
import WebData from '../web_data.js'
import ConfirmDialog from '../confirm_dialog.js'
import LoginInfo from '../login_info.js'

parentNames = ['user']

# Confirm Dialog

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

# Web Data

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

loginInfo = new LoginInfo {}

# Effecters
runCreateUser = (dispatch, {user}) ->
  response = await createWebData.submitPromise {data: {
    csrf()...
    name: user.name
    clearance_level: user.clearance_level
    primary_group: user.primary_group
    attrs: user.attrs
    providers: user.providers
  }}
  if response.ok
    dispatch (state) ->
      state = ChangeUserName(state, user.name)
      state = ChangeMode(state, 'show')
      [state, [runShowLoginInfo, {
        user: response.data
        dateTime: response.dateTime ? DateTime.now()
      }]]
  else
    console.error response

runUpdateUser = (dispatch, {name, user}) ->
  response = await updateWebData.submitPromise {url: "/api/users/#{name}", data: {csrf()..., user...}}
  if response.ok
    dispatch(ChangeMode, 'show')
  else
    console.error response

runDestroyUser = (dispatch, {name}) ->
  confirm = await destroyConfirm.showPromise({message: "ユーザー「#{name}」を削除してもよろしいですか？"})
  if confirm
    response = await destroyWebData.submitPromise {url: "/api/users/#{name}", data: csrf()}
    if response.ok
      # redirect...
    else
      console.error response

runResetPasswordUser = (dispatch, {name}) ->
  confirm = await resetPasswordConfirm.showPromise({message: "ユーザー「#{name}」のパスワードをリセットしてもよろしいですか？"})
  if confirm
    response = await resetPasswordWebData.submitPromise {url: "/api/users/#{name}/password", data: csrf()}
    if response.ok
      # redirect...
    else
      console.error response

runShowLoginInfo = (_dispatch, {user, dateTime}) ->
  await loginInfo.showPromise {
    user
    dateTime
    site: {}
  }

# Actions

CreateUser = (state) -> [state, [runCreateUser, {user: state.user}]]

UreateUser = (state) -> [state, [runUpdateUser, {name: state.name, user: state.user}]]

DestroyUser = (state) -> [state, [runDestroyUser, {name: state.name}]]

ResetPasswordUser = (state) -> [state, [runResetPasswordUser, {name: state.name}]]

ChangeMode = (state, mode) -> {state..., mode}

ChangeUserName = (state, name) ->
  history.pushState(null, null, "/admin/users/#{name}") if name? && name != state.name
  {state..., name}


export default operationMenu = ({mode}) ->
  html.div {}, [
    html.h4 {}, text '操作メニュー'
    html.div {class: 'form-check form-switch'}, [
      html.input {
        id: 'user-mode-edit'
        class: 'form-check-input'
        type: 'checkbox'
        role: 'switch'
        checked: mode != 'show'
        disabled: mode == 'new'
        onchange: [ChangeMode, if mode == 'show' then 'edit' else 'show']
      }
      html.label {
        class: 'form-check-label'
        for: 'user-mode-edit'
      }, text '編集モード'
    ]
    switch mode
      when 'new'
        html.div {},
          html.button {
            class: 'btn btn-primary'
            onclick: CreateUser
          }, text '作成'
      when 'edit'
        html.div {}, [
          html.button {
            class: 'btn btn-warning'
            onclick: UreateUser
          }, text '更新'
          html.button {
            class: 'ms-1 btn btn-danger'
            onclick: DestroyUser
          }, text '削除'
        ]
      when 'show'
        html.div {}, [
          html.div {}, text 'パスワードリセット'
          html.div {}, text 'ロック'
        ]
  ]
