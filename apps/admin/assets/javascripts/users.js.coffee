# /admin/users

import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import BsIcon from '/assets/app/bs_icon.js'
import {pick, pickType, updateList, getQueryParamsFromUrl, entityLabel} from '/assets/common/helper.js'
import {objToUrlencoded} from '/assets/common/convert.js'
import valueDisplay from '/assets/app/value_display.js'

import {
  INDEX_USERS_OPTION_PARAM_TYPES
  INDEX_WITH_PAGE_USERS_PARAM_TYPES, USER_PROPERTIES
  normalizeUser
  createRunIndexWithPageUsers
  createRunShowUser, createRunCreateUser, createRunUpdateUser, createRunDestroyUser
} from '/assets/api/users.js'
import {createRunIndexProviders} from '/assets/api/providers.js'
import {PAGINATION_PARAM_TYPES} from '/assets/api/pagination.js'
import {SEARCH_PARAM_TYPES} from '/assets/api/search.js'
import {ORDER_PARAM_TYPES} from '/assets/api/order.js'

import pageNav from './page_nav.js'
import searchForm from './search_form.js'
import {batchOperation, runDoNextAction, runStopAllAction} from './batch_operation.js'

# mode
#   loading: 読込中
#   loaded: 読込完了
#   file: アップロードされたファイル
#   do_all: 全て実行中
#   result: 実行結果(全てとは限らない)

# Functions

updateUserList = (user, users) -> updateList(user, users, 'name')

normalizeUserUploaded = ({action, error, user...}) ->
  action = action?.slice(0, 3)?.toUpperCase() ? ''
  error = switch action
    when '', 'ADD', 'MOD', 'DEL', 'SYN'
      null
    when 'LOC', 'UNL', 'PAS'
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

indexOptionFromState = (state) ->
  pick({
    state.pagination...
    state.search...
    state.option...
    state.order...
  }, Object.keys(INDEX_WITH_PAGE_USERS_PARAM_TYPES))

# Views

indexUsersOption = ({onchange: action, props...}) ->
  onchange = (state, event) -> [action, {[event.target.name]: event.target.checked}]

  html.div {class: 'row mb-2'},
    for key, val of {
      sync: 'プロバイダーと同期'
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
            onchange
          }
          html.label {class: 'form-check-label', for: id}, text val
        ]

providerTh = ({provider}) ->
  html.th {key: "provider[#{provider.name}]"}, text entityLabel(provider)

userProviderTd = ({user, provider}) ->
  html.td {key: "provider[#{provider.name}]"},
    valueDisplay {
      value: user.providers?.get(provider.name)
      type: 'boolean'
    }

userTr = ({user, providers}) ->
  color = switch user.action
    when 'ADD'
      'primary'
    when 'MOD', 'UNL'
      'info'
    when 'DEL', 'LOC'
      'waring'
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
    key: "user[#{user.name}]"
    class: "table-#{color}"
  }, [
    html.td {
      key: 'show'
      onclick: -> [SetUserInList, {user..., show_detail: !user.show_detail}]
    }, BsIcon {name: if user.show_detail then 'chevron-down' else 'chevron-right'}
    html.td {key: 'action'},
      switch user.action
        when 'ACT'
          html.div {class: 'spinner-border spinner-border-sm', role: 'status'},
            html.span {class: 'visually-hidden'}, text '実行中'
        when 'ADD', 'MOD', 'SYN', 'DEL', 'LOC', 'UNL'
          html.button {
            class: "btn btn-sm btn-#{color}"
            onclick: -> [DoActionUser, user]
          }, text user.action
        when 'ERR'
          html.div {}, text 'エラー'
        else
          html.a {href: "/admin/users/#{user.name}"}, text '閲覧'
    html.td {key: 'name'}, text user.name
    html.td {key: 'label'}, [
      html.span {}, text entityLabel(user)
      html.span {class: 'ms-2 badge text-bg-warning'}, text '使用禁止' if user.prohibited
      html.span {class: 'ms-2 badge text-bg-danger'}, text '削除済み' if user.deleted
    ]
    html.td {key: 'label'}, text user.display_name
    html.td {key: 'email'}, text user.email ? ''
    html.td {key: 'clearance_level'}, text user.clearance_level
    (userProviderTd({user, provider}) for provider in providers)...
  ]

userDetailTr = ({user, colspan}) ->
  html.tr {
    key: "user-detail[#{user.name}]"
    class: {collapse: true, show: user.show_detail}
  },
    html.td {colspan}, [
      html.div {key: 'properties'}, [
        unless user.action
          html.button {
            key: 'sync'
            class: 'btn btn-sm btn-light'
            onclick: -> [SyncUser, user]
          }, text '同期'
        html.span {key: 'display_name'}, text "表示名: #{user.display_name || '(無し)'}"
        html.span {key: 'deleted_at', class: 'ms-2'}, text "削除日: #{user.deleted_at}" if user.deleted_at
      ]
      if user.note
        html.div {key: 'note'},
          html.pre {class: 'mb-0 text-info'}, text user.note
      if user.error
        html.div {key: 'error'},
          html.pre {class: 'mb-0 text-danger'},
            text if typeof user.error == 'string'
              user.error
            else
              JSON.stringify(user.error, null, 2)
    ]

# Actions

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
    {
      show_detail: false
      normalizeUserUploaded(user)...
    }
  {
    state...
    mode: 'file'
    users
    filename
  }

SetUserInList = (state, user) ->
  {
    state...
    users: updateUserList(user, state.users)
  }

SetUserInListNextIfDoAll = (state, user) ->
  users = updateUserList(user, state.users)
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
  switch user.action
    when 'MOD'
      [ModUser, user]
    when 'SYN'
      [SyncUser, user]
    else
      console.warn 'not implemented action: %s', user.action
      state

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
        users: updateUserList({user..., action: 'ACT'}, state.users)
      }
      [run, {props..., user..., id: user.name}]
    ]

ModUser = createActionUser(createRunUpdateUser)

SyncUser = createActionUser(createRunShowUser, {sync: true})

PopState = (state, params) ->
  data = {
    pagination: {state.pagination..., pickType(params, PAGINATION_PARAM_TYPES)...}
    search: {state.search..., pickType(params, SEARCH_PARAM_TYPES)...}
    option: {state.option..., pickType(params, INDEX_USERS_OPTION_PARAM_TYPES)...}
    order: {state.order..., pickType(params, ORDER_PARAM_TYPES)...}
  }
  [ReloadIndexUsers, data]

# Effecters

runIndexProviders = createRunIndexProviders()

runIndexUsers = createRunIndexWithPageUsers({action: SetIndexUsers})

runPushHistory = (dispatch, params) ->
  query = "?#{objToUrlencoded(params)}"
  if (query != location.search)
    history.pushState(params, '', "#{location.pathname}#{query}")

# Subscribers

onPopstateSubscriber = (dispatch, action) ->
  listener = (event) -> dispatch(action, event.state)
  window.addEventListener 'popstate', listener
  -> window.removeEventListener 'popstate', listener

# create Subscriver
onPopstate = (action)->
  [onPopstateSubscriber, action]

# main
main = ->
  queryParams = getQueryParamsFromUrl(location)

  initState = {
    mode: 'loading'
    users: []
    providers: []
    pagination: pickType(queryParams, PAGINATION_PARAM_TYPES)
    search: pickType(queryParams, SEARCH_PARAM_TYPES)
    option: pickType(queryParams, INDEX_USERS_OPTION_PARAM_TYPES)
    order: pickType(queryParams, ORDER_PARAM_TYPES)
    filename: 'users.csv'
  }

  init = [
    initState
    [runIndexProviders]
    [runIndexUsers, indexOptionFromState(initState)]
  ]

  view = ({mode, users, providers, pagination, search, option, order, filename}) ->
    html.div {}, [
      batchOperation {
        mode
        list: users
        headers: [
          'action'
          Object.keys(USER_PROPERTIES)...
          ("providers[#{provider.name}]" for provider in providers)...
          'error'
        ]
        filename
        onupload: UploadUsers
        action: DoActionUser
      }
      if mode != 'upload'
        html.div {key: 'index-params'}, [
          searchForm {search..., onsearch: Search}
          indexUsersOption {option..., onchange: ChangeOption}
          pageNav {pagination..., onpage: MovePage}
        ]
      if mode == 'loading'
        html.p {}, text '読込中...'
      else if users.length == 0
        html.p {}, text 'ユーザーが存在しません。'
      else
        html.table {class: 'table'}, [
          html.thead {},
            html.tr {}, [
              html.th {key: 'show'}, text ''
              html.th {key: 'action'}, text 'アクション'
              html.th {key: 'name'}, text 'ユーザー名'
              html.th {key: 'label'}, text 'ラベル'
              html.th {key: 'email'}, text 'メールアドレス'
              html.th {key: 'clearance-level'}, text '権限レベル'
              (providerTh({provider}) for provider in providers)...
            ]
          html.tbody {},
            (for user in users
              [
                userTr({user, providers})
                userDetailTr({user, colspan: 6 + providers.length})
              ]
            ).flat()
        ]
    ]

  node = document.getElementById('users')

  subscriptions = ({mode}) ->
    [
      onPopstate(PopState) if ['loading', 'loaded'].includes(mode)
    ]

  app {init, view, node, subscriptions}

main()