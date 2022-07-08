import {text} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

import {fieldName, fieldId} from '../form_helper.js'
import csrf from '../csrf.js'
import WebData from '../web_data.js'
import ConfirmDialog from '../confirm_dialog.js'

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


# Effects

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
  confirm = await destroyConfirm.confirmPromise({message: "ユーザー「#{name}」を削除してもよろしいですか？"})
  if confirm
    response = await destroyWebData.submitPromise {url: "/api/users/#{name}", data: csrf()}
    if response.ok
      # redirect...
    else
      console.error response

# Actions

destroyUserAction = (state) -> [state, [destroyUserRunner, {name: state.name}]]

createUserAction = (state) -> [state, [createUserRunner, {user: state.user}]]

updateUserAction = (state) -> [state, [updateUserRunner, {name: state.name, user: state.user}]]

changeMode = (state, mode) -> {state..., mode}

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
        onchange: [changeMode, if mode == 'show' then 'edit' else 'show']
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
            onclick: createUserAction
          }, text '作成'
      when 'edit'
        html.div {}, [
          html.button {
            class: 'btn btn-warning'
            onclick: updateUserAction
          }, text '更新'
          html.button {
            class: 'ms-1 btn btn-danger'
            onclick: destroyUserAction
          }, text '削除'
        ]
      when 'show'
        html.div {}, [
          html.div {}, text 'パスワードリセット'
          html.div {}, text 'ロック'
        ]
  ]
