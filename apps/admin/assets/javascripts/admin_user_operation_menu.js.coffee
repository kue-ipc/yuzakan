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
  action: {
    color: 'danger'
    label: '削除'
  }
}

createPasswordConfirm = new ConfirmDialog {
  id: fieldId('creaet', ['modal', 'confirm', parentNames..., 'password'])
  status: 'warn'
  title: 'パスワードのリセット'
  action: {
    color: 'warning'
    label: 'パスワードリセット'
  }
}

# Web Data

createWebData = new WebData {
  id: fieldId('create', ['modal', 'web', parentNames...])
  title: 'ユーザーの作成'
  method: 'POST'
  url: '/api/users'
  codeActions: new Map [
    [201, {status: 'success', message: 'ユーザーを作成しました。', autoCloseTime: 1}]
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

createPasswordWebData = new WebData {
  id: fieldId('create', ['modal', 'web', parentNames..., 'password'])
  title: 'パスワードのリセット'
  method: 'POST'
  codeActions: new Map [
    [201, {status: 'success', message: 'パスワードをリセットしました。', autoCloseTime: 1}]
  ]
}

loginInfo = new LoginInfo {
  id: fieldId('login_inof', ['modal', 'login_info', parentNames...])
}

# Effecters
runCreateUser = (dispatch, {user}) ->
  response = await createWebData.submitPromise {
    data: {
      csrf()...
      username: user.username
      display_name: user.display_name
      email: user.email
      clearance_level: user.clearance_level
      primary_group: user.primary_group
      attrs: user.attrs
      providers: user.providers
    }
  }
  if response.ok
    dispatch (state) ->
      state = ChangeUserName(state, user.username)
      state = ChangeMode(state, 'show')
      [state, [runShowLoginInfo, {user: response.data, dateTime: response.dateTime ? DateTime.now()}]]
  else
    console.error response

runUpdateUser = (dispatch, {name, user}) ->
  response = await updateWebData.submitPromise {
    url: "/api/users/#{name}"
    data: {
      csrf()...
      username: user.username
      display_name: user.display_name
      email: user.email
      clearance_level: user.clearance_level
      primary_group: user.primary_group
      attrs: user.attrs
      providers: user.providers
    }
  }
  if response.ok
    dispatch(ChangeMode, 'show')
  else
    console.error response

runDestroyUser = (dispatch, {name}) ->
  confirm = await destroyConfirm.showPromise({
    messages: ["ユーザー「#{name}」を削除してもよろしいですか？"]
  })
  if confirm
    response = await destroyWebData.submitPromise {url: "/api/users/#{name}", data: csrf()}
    if response.ok
      # redirect...
    else
      console.error response

runCreatePasswordUser = (dispatch, {name}) ->
  confirm = await createPasswordConfirm.showPromise({
    messages: ["ユーザー「#{name}」のパスワードをリセットしてもよろしいですか？"]
  })
  if confirm
    response = await createPasswordWebData.submitPromise {url: "/api/users/#{name}/password", data: csrf()}
    if response.ok
      dispatch (state) ->
        [state, [runShowLoginInfo, {user: response.data, dateTime: response.dateTime ? DateTime.now()}]]
    else
      console.error response

runShowLoginInfo = (_dispatch, {user, dateTime}) ->
  loginInfo.showPromise {user, dateTime, site: {}}

# Actions

CreateUser = (state) -> [state, [runCreateUser, {user: state.user}]]

UreateUser = (state) -> [state, [runUpdateUser, {name: state.name, user: state.user}]]

DestroyUser = (state) -> [state, [runDestroyUser, {name: state.name}]]

CreatPasswordUser = (state) -> [state, [runCreatePasswordUser, {name: state.name}]]

CreatLockUser = (state) -> state
DeleteLockUser = (state) -> state

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
          html.button {
            class: 'btn btn-warning'
            onclick: CreatPasswordUser
          }, text 'パスワードリセット'
          html.button {
            class: 'btn btn-primary ms-2'
            onclick: CreatLockUser
          }, text 'ロック'
          html.button {
            class: 'btn btn-secondary ms-2'
            onclick: DeleteLockUser
          }, text 'アンロック'
        ]
  ]
