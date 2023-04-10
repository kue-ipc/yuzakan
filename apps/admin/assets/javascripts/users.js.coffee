# /admin/users

import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'
import {DateTime} from '/assets/vendor/luxon.js'

import {pick, pickType, getQueryParamsFromUrl, entityLabel} from '/assets/common/helper.js'
import {convertToType, objToUrlencoded, objToJson, listToParamName} from '/assets/common/convert.js'
import {updateList, findList} from '/assets/common/list_helper.js'

import bsIcon from '/assets/app/bs_icon.js'
import valueDisplay from '/assets/app/value_display.js'
import preCode from '/assets/app/pre_code.js'
import LoginInfo from '/assets/app/login_info.js'

import {
  USER_PROPERTIES, USER_DATA_PROPERTIES
  INDEX_USERS_OPTION_PARAM_TYPES, INDEX_WITH_PAGE_USERS_PARAM_TYPES
  normalizeUser
  createRunIndexWithPageUsers
  createRunShowUser, createRunCreateUser, createRunUpdateUser, createRunDestroyUser
} from '/assets/api/users.js'
import {createRunCreateUserLock, createRunDestroyUserLock} from '/assets/api/users_lock.js'
import {runIndexGroupsNoSync} from '/assets/api/groups.js'
import {runIndexProviders} from '/assets/api/providers.js'
import {runIndexAttrs} from '/assets/api/attrs.js'
import {runShowSystem} from '/assets/api/system.js'

import {PAGINATION_PARAM_TYPES} from '/assets/api/pagination.js'
import {SEARCH_PARAM_TYPES} from '/assets/api/search.js'
import {ORDER_PARAM_TYPES} from '/assets/api/order.js'

import pageNav from '/assets/admin/page_nav.js'
import searchForm from '/assets/admin/search_form.js'
import {batchOperation, runDoNextAction, runStopAllAction} from '/assets/admin/batch_operation.js'
import {setUserAttrsDefault} from '/assets/admin/user_attrs.js'


# mode
#   loading: 読込中
#   loaded: 読込完了
#   file: アップロードされたファイル
#   do_all: 全て実行中
#   result: 実行結果(全てとは限らない)

# Cnostants

USER_HEADERS = ['action']
  .concat(key for key, type of USER_PROPERTIES when !(['list', 'map', 'set', 'object'].includes(type)))

ACTIONS = new Map([
  ['ADD', '追加']
  ['MOD', '変更']
  ['DEL', '削除']
  ['ERR', 'エラー']
  ['SUC', '成功']
  ['ACT', '実行中']
  ['SYN', '同期']
  ['LOC', 'ロック']
  ['UNL', 'アンロック']
])

# Functions

updateUserList = (users, user) -> updateList(users, user.name, user, {key: 'name'})

normalizeUserUploaded = ({action, error, user...}) ->
  action = action?.slice(0, 3)?.toUpperCase() ? ''
  error = switch action
    when '', 'ADD', 'MOD', 'DEL', 'SYN', 'LOC', 'UNL'
      null
    when 'PAS'
      'この処理は対応していません。'
    when 'ERR', 'SUC', 'ACT'
      error
    else
      action = 'ERR'
      '指定した処理が不正です。'
  {
    action
    error
    normalizeUser(user)...
  }

normalizeUserAttrs = (userAttrs, {attrs}) ->
  newAttrs = for attr in attrs when attr.name of userAttrs
    [attr.name, convertToType(userAttrs[attr.name], attr.type)]
  new Map(newAttrs)

fillAddOrModUsers = ({users, attrs, domain}) ->
  for user in users
    user = setUserAttrsDefault({user, attrs}) if user.attrs? && ['ADD', 'MOD'].includes(user.action)
    user = {user..., email: "#{user.name}@#{domain}"} if user.action == 'ADD' && !user.email
    user

indexOptionFromState = (state) ->
  pick({
    state.pagination...
    state.search...
    state.option...
    state.order...
  }, Object.keys(INDEX_WITH_PAGE_USERS_PARAM_TYPES))

userHeaders = ({attrs}) ->
  [
    USER_HEADERS...
    (listToParamName('attrs', attr.name) for attr in attrs)...
  ]

# Dialogs

loginInfo = new LoginInfo {
  id: 'users-login_info'
}

# Hyperapp Components

## Views

indexUsersOption = ({onchange: action, readonly = false, props...}) ->
  onchange = (state, event) -> [action, {[event.target.name]: event.target.checked}]

  html.div {class: 'row mb-2'},
    for key, val of {
      no_sync: 'プロバイダーと同期しない'
      hide_prohibited: '使用禁止を隠す'
      show_deleted: '削除済みも表示'
    }
      id = "option-#{key}"
      html.div {key: "option[#{key}]", class: 'col-md-3'},
        html.div {class: 'form-check'}, [
          html.input {
            id
            class: 'form-check-input'
            name: key
            type: 'checkbox'
            checked: props[key]
            disabled: readonly
            onchange
          }
          html.label {class: 'form-check-label', for: id}, text val
        ]

usersTable = ({users, groups, providers}) ->
  html.table {key: 'table', class: 'table'}, [
    usersThead({providers})
    usersTbody({users, groups, providers})
  ]

usersThead = ({providers}) ->
  html.thead {key: 'thead'},
    html.tr {key: 'head'}, [
      html.th {key: 'show'}, text ''
      html.th {key: 'action'}, text 'アクション'
      html.th {key: 'name'}, text 'ユーザー名'
      html.th {key: 'label'}, text 'ラベル'
      html.th {key: 'email'}, text 'メールアドレス'
      html.th {key: 'clearance-level'}, text '権限レベル'
      html.th {key: 'primary-group'}, text 'プライマリグループ'
      (providerTh({provider}) for provider in providers)...
    ]

providerTh = ({provider}) ->
  html.th {key: "provider[#{provider.name}]"}, text entityLabel(provider)

usersTbody = ({users, groups, providers}) ->
  html.tbody {key: 'tbody'},
    (for user in users
      [
        userTr({user, groups, providers})
        userDetailTr({user, providers})
      ]
    ).flat()

userTr = ({user, groups, providers}) ->
  color = switch user.action
    when 'ADD'
      'primary'
    when 'MOD', 'UNL'
      'info'
    when 'DEL', 'LOC'
      'warning'
    when 'ERR'
      'danger'
    when 'SUC'
      'success'
    when 'ACT'
      'secondary'
    when 'SYN'
      'light'
    else
      'light'
  html.tr {
    id: "user_tr-#{user.name}"
    key: "user[#{user.name}]"
    class: "table-#{color}"
  }, [
    html.td {
      key: 'show'
      onclick: -> [SetUserInList, {user..., show_detail: !user.show_detail}]
    }, bsIcon {name: if user.show_detail then 'chevron-down' else 'chevron-right'}
    html.td {key: 'action'},
      switch user.action
        when ''
          html.button {
            class: "btn btn-sm btn-outline-dark"
            onclick: -> [SyncUser, user]
          }, text '取得'
        when 'ACT'
          html.div {class: 'spinner-border spinner-border-sm', role: 'status'},
            html.span {class: 'visually-hidden'}, text '実行中'
        when 'ADD', 'MOD', 'SYN', 'DEL', 'LOC', 'UNL'
          html.button {
            class: "btn btn-sm btn-#{color}"
            onclick: -> [DoActionUser, user]
          }, text ACTIONS.get(user.action)
        when 'ERR'
          html.div {}, text 'エラー'
        when 'SUC'
          if user.password
            html.button {
              class: "btn btn-sm btn-primary"
              onclick: (state) -> [state, [runShowLoginInfo, {user}]]
            }, text '情報'
          else
            html.div {}, text '成功'
        else
          html.a {href: "/admin/users/#{user.name}"}, text '閲覧'
    html.td {key: 'name'},
      html.a {href: "/admin/users/#{user.name}"}, text user.name
    html.td {key: 'label'}, [
      html.span {}, text entityLabel(user)
      html.span {class: 'ms-2 badge text-bg-warning'}, text '使用禁止' if user.prohibited
      html.span {class: 'ms-2 badge text-bg-danger'}, text '削除済み' if user.deleted
    ]
    html.td {key: 'email'}, text user.email ? ''
    html.td {key: 'clearance-level'}, text user.clearance_level ? ''
    html.td {key: 'primary-group'},
      if user.primary_group
        html.a {href: "/admin/groups/#{user.primary_group}"},
          text entityLabel(findList(groups, user.primary_group, {key: 'name'})) ? user.primary_group
      else
        undefined
    (userProviderTd({user, provider}) for provider in providers)...
  ]

userProviderTd = ({user, provider}) ->
  html.td {key: "provider[#{provider.name}]"},
    valueDisplay {
      value: user.providers?.includes(provider.name)
      type: 'boolean'
    }

userDetailTr = ({user, providers}) ->
  html.tr {
    key: "user-detail[#{user.name}]"
    class: {collapse: true, show: user.show_detail}
  }, [
    html.td {key: 'space'}
    html.td {key: 'detail', colspan: 5}, [
      html.div {key: 'properties'}, [
        html.span {key: 'display_name'}, text "表示名: #{user.display_name || '(無し)'}"
        html.span {key: 'deleted_at', class: 'ms-2'}, text "削除日: #{user.deleted_at}" if user.deleted_at
      ]
      if user.attrs?
        html.div {key: 'attrs', class: 'small'},
          preCode {code: objToJson(user.attrs, 2), language: 'json'}
      if user.note
        html.div {key: 'note', class: 'small'},
          html.pre {class: 'mb-0 text-info'}, text user.note
      if user.error
        html.div {key: 'error', class: 'small'},
          if typeof user.error == 'string'
            preCode {code: user.error, language: 'text'}
          else
            preCode {code: objToJson(user.error, 2), language: 'json'}
    ]
    html.td {key: 'groups'},
      html.div {}, text user.groups?.join(', ') ? ''
    (userProviderDataTd({user, provider}) for provider in providers)...
  ]

userProviderDataTd = ({user, provider}) ->
  html.td {key: "provider-data[#{provider.name}]"},
    if user.providers_data?.has(provider.name)
      html.div {key: 'data', class: 'small'},
        preCode {code: objToJson(user.providers_data.get(provider.name), 2), language: 'json'}

## Action Creaters

createActionUser = (createEffecter, props = {}) ->
  (state, user) ->
    action = (_, data) ->
      if data?
        [SetUserInListNextIfDoAll, {user..., data..., action: 'SUC', error: null}]
      else
        [SetUserInListNextIfDoAll, {user..., action: 'ERR', error: '存在しません。', show_detail: true}]
    fallback = (_, error) ->
      [SetUserInListNextIfDoAll, {user..., action: 'ERR', error, show_detail: true}]
    run = createEffecter({action, fallback})
    [
      {
        state...
        mode: if state.mode == 'file' then 'result' else state.mode
        users: updateUserList(state.users, {user..., action: 'ACT'})
      }
      [run, {props..., user..., id: user.name, user_id: user.name}]
    ]

## Actions

runShowLoginInfo = (_dispatch, {user, dateTime = DateTime.now()}) ->
  loginInfo.showPromise {user, dateTime, site: {}}

ReloadIndexUsers = (state, data) ->
  console.debug 'reload index users'
  newState = {state..., data..., mode: 'loading'}
  params = indexOptionFromState(newState)
  [
    newState,
    [runPushHistory, params]
    [runIndexUsers, params]
  ]

SetIndexUsers = (state, rawUsers) ->
  console.debug 'finish load users'
  users = for user in rawUsers
    {
      action: ''
      show_detail: false
      error: null
      user...
    }
  {
    state...
    mode: 'loaded'
    users
  }

MovePage = (state, page) ->
  return state if state.page == page

  [ReloadIndexUsers, {pagination: {state.pagination... , page}}]

Search = (state, query) ->
  return state if state.query == query

  # ページ情報を初期化
  [ReloadIndexUsers, {pagination: {state.pagination... , page: 1}, search: {query}}]

ChangeOption = (state, option) ->
  # ページ情報を初期化
  [ReloadIndexUsers, {pagination: {state.pagination... , page: 1}, option: {state.option..., option...}}]

SortOrder = (state, order) ->
  [ReloadIndexUsers, {order}]

UploadUsers = (state, {list, filename}) ->
  users = for user in list
    userAttrs = if user.attrs?
      {attrs: normalizeUserAttrs(user.attrs, {attrs: state.attrs})}
    else
      {}
    {
      show_detail: false
      normalizeUserUploaded(user)...
      userAttrs...
    }

  
  {
    state...
    mode: 'file'
    users: fillAddOrModUsers({users, attrs: state.attrs, domain: state.system?.domain})
    filename
  }

SetUserInList = (state, user) ->
  {
    state...
    users: updateUserList(state.users, user)
  }

SetUserInListNextIfDoAll = (state, user) ->
  users = updateUserList(state.users, user)
  [
    {
      state...
      users
    }
    if user.action == 'ERR'
      runStopAllAction
    else if state.mode == 'do_all'
      [runDoNextAction, {list: users, action: DoActionUser}]
  ]

DoActionUser = (state, user) ->
  document.getElementById("user_tr-#{user.name}")?.scrollIntoView({block: 'center'})
  switch user.action
    when 'ADD'
      [AddUser, user]
    when 'MOD'
      [ModUser, user]
    when 'DEL'
      [DelUser, {user..., permanent: user.deleted}]
    when 'SYN'
      [SyncUser, user]
    when 'LOC'
      [LockUser, user]
    when 'UNL'
      [UnlockUser, user]
    else
      console.warn 'not implemented action: %s', user.action
      state

AddUser = createActionUser(createRunCreateUser)

ModUser = createActionUser(createRunUpdateUser)

DelUser = createActionUser(createRunDestroyUser)

SyncUser = createActionUser(createRunShowUser)

LockUser = createActionUser(createRunCreateUserLock)

UnlockUser = createActionUser(createRunDestroyUserLock)

PopState = (state, params) ->
  data = {
    pagination: {state.pagination..., pickType(params, PAGINATION_PARAM_TYPES)...}
    search: {state.search..., pickType(params, SEARCH_PARAM_TYPES)...}
    option: {state.option..., pickType(params, INDEX_USERS_OPTION_PARAM_TYPES)...}
    order: {state.order..., pickType(params, ORDER_PARAM_TYPES)...}
  }
  [ReloadIndexUsers, data]

## Effecters

runIndexUsers = createRunIndexWithPageUsers({action: SetIndexUsers})

runPushHistory = (dispatch, params) ->
  query = "?#{objToUrlencoded(params)}"
  if (query != location.search)
    history.pushState(params, '', "#{location.pathname}#{query}")

## Subscribers

onPopstateSubscriber = (dispatch, action) ->
  listener = (event) -> dispatch(action, event.state)
  window.addEventListener 'popstate', listener
  -> window.removeEventListener 'popstate', listener

## Subscription Generators
onPopstate = (action)->
  [onPopstateSubscriber, action]

# main
main = ->
  queryParams = getQueryParamsFromUrl(location)

  initState = {
    mode: 'loading'
    users: []
    groups: []
    providers: []
    attrs: []
    pagination: pickType(queryParams, PAGINATION_PARAM_TYPES)
    search: pickType(queryParams, SEARCH_PARAM_TYPES)
    option: pickType(queryParams, INDEX_USERS_OPTION_PARAM_TYPES)
    order: pickType(queryParams, ORDER_PARAM_TYPES)
    filename: 'users.csv'
  }

  init = [
    initState
    [runShowSystem]
    [runIndexProviders]
    [runIndexAttrs]
    [runIndexGroupsNoSync]
    [runIndexUsers, indexOptionFromState(initState)]
  ]

  view = ({mode, users, groups, providers, attrs, pagination, search, option, order, filename}) ->
    html.div {}, [
      batchOperation {
        mode
        list: users
        header: {
          includes: userHeaders({attrs})
          excludes: ['show_detail']
        }
        filename
        onupload: UploadUsers
        action: DoActionUser
      }
      if mode == 'loaded' || mode == 'loading'
        html.div {key: 'index-params'}, [
          searchForm {search..., onsearch: Search, readonly: mode == 'loading'}
          indexUsersOption {option..., onchange: ChangeOption, readonly: mode == 'loading'}
          pageNav {pagination..., onpage: MovePage, readonly: mode == 'loading'}
        ]
      if mode == 'loading'
        html.p {}, text '読込中...'
      else if users.length == 0
        html.p {}, text 'ユーザーが存在しません。'
      else
        usersTable({users, groups, providers})
    ]

  node = document.getElementById('users')

  subscriptions = ({mode}) ->
    [
      onPopstate(PopState) if ['loading', 'loaded'].includes(mode)
    ]

  app {init, view, node, subscriptions}

main()