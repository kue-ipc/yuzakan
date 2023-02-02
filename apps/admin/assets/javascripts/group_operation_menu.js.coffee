import {text} from '/assets/hyperapp.js'
import * as html from '/assets/hyperapp-html.js'
import {DateTime} from '/assets/luxon.js'

import {fieldName, fieldId} from '/assets/form_helper.js'
import csrf from '/assets/csrf.js'
import WebData from '/assets/web_data.js'
import ConfirmDialog from '/assets/confirm_dialog.js'
import LoginInfo from '/assets/login_info.js'

# import {runGetGroupWithInit} from './admin_group_get_group.js'

parentNames = ['group']

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
  id: fieldId('create', ['modal', 'confirm', parentNames..., 'password'])
  status: 'warn'
  title: 'パスワードのリセット'
  action: {
    color: 'warning'
    label: 'パスワードリセット'
  }
}

createLockConfirm = new ConfirmDialog {
  id: fieldId('create', ['modal', 'confirm', parentNames..., 'lock'])
  status: 'info'
  title: 'ユーザーのロック'
  action: {
    color: 'primary'
    label: 'ユーザーロック'
  }
}

destroyLockConfirm = new ConfirmDialog {
  id: fieldId('destroy', ['modal', 'confirm', parentNames..., 'lock'])
  status: 'info'
  title: 'ユーザーのアンロック'
  action: {
    color: 'secondary'
    label: 'ユーザーロック'
  }
}

# Web Data

createWebData = new WebData {
  id: fieldId('create', ['modal', 'web', parentNames...])
  title: 'ユーザーの作成'
  method: 'POST'
  url: '/api/groups'
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
    [200, {status: 'success', message: 'ユーザーを削除しました。', redirectTo: '/admin/groups', reloadTime: 10}]
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

createLockWebData = new WebData {
  id: fieldId('create', ['modal', 'web', parentNames..., 'lock'])
  title: 'ユーザーのロック'
  method: 'POST'
  codeActions: new Map [
    [201, {status: 'success', message: 'ユーザーをロックしました。'}]
  ]
}

destroyLockWebData = new WebData {
  id: fieldId('destroy', ['modal', 'web', parentNames..., 'lock'])
  title: 'ユーザーのアンロック'
  method: 'DELETE'
  codeActions: new Map [
    [200, {status: 'success', message: 'ユーザーをアンロックしました。'}]
  ]
}

loginInfo = new LoginInfo {
  id: fieldId('login_inof', ['modal', 'login_info', parentNames...])
}

# Effecters
runCreateGroup = (dispatch, {group}) ->
  response = await createWebData.submitPromise {
    data: {
      csrf()...
      groupname: group.groupname
      display_name: group.display_name
      email: group.email
      clearance_level: group.clearance_level
      primary_group: group.primary_group
      attrs: group.attrs
      providers: group.providers
    }
  }
  if response.ok
    dispatch (state) ->
      state = ChangeGroupName(state, group.groupname)
      state = ChangeMode(state, 'show')
      [state, [runShowLoginInfo, {group: response.data, dateTime: response.dateTime ? DateTime.now()}]]
  else
    console.error response

runUpdateGroup = (dispatch, {name, group}) ->
  response = await updateWebData.submitPromise {
    url: "/api/groups/#{name}"
    data: {
      csrf()...
      groupname: group.groupname
      display_name: group.display_name
      email: group.email
      clearance_level: group.clearance_level
      primary_group: group.primary_group
      attrs: group.attrs
      providers: group.providers
    }
  }
  if response.ok
    dispatch(ReadGroup)
    dispatch(ChangeMode, 'show')
  else
    console.error response

runDestroyGroup = (dispatch, {name}) ->
  confirm = await destroyConfirm.showPromise({
    messages: ["ユーザー「#{name}」を削除してもよろしいですか？"]
  })
  if confirm
    response = await destroyWebData.submitPromise {url: "/api/groups/#{name}", data: csrf()}
    if response.ok
      # redirect...
    else
      console.error response

runCreatePasswordGroup = (dispatch, {name}) ->
  confirm = await createPasswordConfirm.showPromise({
    messages: ["ユーザー「#{name}」のパスワードをリセットしてもよろしいですか？"]
  })
  if confirm
    response = await createPasswordWebData.submitPromise {url: "/api/groups/#{name}/password", data: csrf()}
    if response.ok
      dispatch (state) ->
        [state, [runShowLoginInfo, {group: response.data, dateTime: response.dateTime ? DateTime.now()}]]
    else
      console.error response

runCreateLockGroup = (dispatch, {name}) ->
  confirm = await createLockConfirm.showPromise({
    messages: ["ユーザー「#{name}」をロックしてもよろしいですか？"]
  })
  if confirm
    response = await createLockWebData.submitPromise {url: "/api/groups/#{name}/lock", data: csrf()}
    if response.ok
      dispatch(ReadGroup)
    else
      console.error response

runDestroyLockGroup = (dispatch, {name}) ->
  confirm = await destroyLockConfirm.showPromise({
    messages: ["ユーザー「#{name}」をアンロックしてもよろしいですか？"]
  })
  if confirm
    response = await destroyLockWebData.submitPromise {url: "/api/groups/#{name}/lock", data: csrf()}
    if response.ok
      dispatch(ReadGroup)
    else
      console.error response

runShowLoginInfo = (_dispatch, {group, dateTime}) ->
  loginInfo.showPromise {group, dateTime, site: {}}

# Actions
ReadGroup = (state) -> [state, [runGetGroupWithInit, {name: state.name}]]

CreateGroup = (state) -> [state, [runCreateGroup, {group: state.group}]]

UreateGroup = (state) -> [state, [runUpdateGroup, {name: state.name, group: state.group}]]

DestroyGroup = (state) -> [state, [runDestroyGroup, {name: state.name}]]

CreatPasswordGroup = (state) -> [state, [runCreatePasswordGroup, {name: state.name}]]

CreatLockGroup = (state) -> [state, [runCreateLockGroup, {name: state.name}]]

DestroyLockGroup = (state) -> [state, [runDestroyLockGroup, {name: state.name}]]

ChangeMode = (state, mode) -> {state..., mode}

ChangeGroupName = (state, name) ->
  history.pushState(null, null, "/admin/groups/#{name}") if name? && name != state.name
  {state..., name}


export default operationMenu = ({mode}) ->
  html.div {}, [
    html.h4 {}, text '操作メニュー'
    html.div {class: 'form-check form-switch'}, [
      html.input {
        id: 'group-mode-edit'
        class: 'form-check-input'
        type: 'checkbox'
        role: 'switch'
        checked: mode != 'show'
        disabled: mode == 'new'
        onchange: [ChangeMode, if mode == 'show' then 'edit' else 'show']
      }
      html.label {
        class: 'form-check-label'
        for: 'group-mode-edit'
      }, text '編集モード'
    ]
    switch mode
      when 'new'
        html.div {},
          html.button {
            class: 'btn btn-primary'
            onclick: CreateGroup
          }, text '作成'
      when 'edit'
        html.div {}, [
          html.button {
            class: 'btn btn-warning'
            onclick: UreateGroup
          }, text '更新'
          html.button {
            class: 'ms-1 btn btn-danger'
            onclick: DestroyGroup
          }, text '削除'
        ]
      when 'show'
        html.div {}, [
          html.button {
            class: 'btn btn-warning'
            onclick: CreatPasswordGroup
          }, text 'パスワードリセット'
          html.button {
            class: 'btn btn-primary ms-2'
            onclick: CreatLockGroup
          }, text 'ロック'
          html.button {
            class: 'btn btn-secondary ms-2'
            onclick: DestroyLockGroup
          }, text 'アンロック'
        ]
  ]
