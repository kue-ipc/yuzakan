import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import BsIcon from '/assets/bs_icon.js'
import {pick, pickType, updateList, getQueryParamsFromUrl, entityLabel} from '/assets/utils.js'
import {objToUrlencoded} from '/assets/form_helper.js'
import valueDisplay from '/assets/value_display.js'
import ConfirmDialog from '/assets/confirm_dialog.js'
import {fieldId} from '/assets/form_helper.js'

import {
  INDEX_WITH_PAGE_USRERS_PARAM_TYPES, USER_PROPERTIES
  normalizeGroup
  createRunIndexWithPageUser
  createRunShowUser, createRunCreatUser, createRunUpdateUser, createRunDestroyUser
} from '/assets/api/users.js'
import {createRunIndexProviders} from '/assets/api/providers.js'
import {PAGINATION_PARAM_TYPES} from '/assets/api/pagination.js'
import {SEARCH_PARAM_TYPES} from '/assets/api/search.js'
import {ORDER_PARAM_TYPES} from '/assets/api/order.js'

import pageNav from './page_nav.js'
import searchForm from './search_form.js'
import {downloadButton, uploadButton} from './csv.js'

# Functions

updateUserList = (user, users) -> updateList(user, users, 'name')

normalizeUserUploaded = ({action, error, user...}) ->
  action = action?.slice(0, 3)?.toUpperCase() ? ''
  error = switch action
    when '', 'ADD', 'MOD', 'DEL'
      null
    when 'LOC', 'UNL', 'RES', 'SYC'
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

providerTh = ({provider}) ->
  html.th {}, text provider.label

userProviderTd = ({user, provider}) ->
  if user.provider_names.includes(provider.name)
    html.td {class: 'text-success'},
      BsIcon({name: 'check-square'})
  else
    html.td {class: 'text-muted'},
      BsIcon({name: 'square'})

userTr = ({user, providers}) ->
  html.tr {}, [
    html.td {},
      html.a {href: "/admin/users/#{user.name}"}, text user.name
    html.td {}, text user.display_name
    html.td {}, text user.email ? ''
    html.td {}, text user.clearance_level
    (userProviderTd({user, provider}) for provider in providers)...
  ]

runPageUsersHistory = (dispatch, {page, per_page, query}) ->
  data = {page, per_page, query}
  query = "?#{objToUrlencoded(data)}"
  if (query != location.search)
    history.pushState(data, 'users', "/admin/users?#{objToUrlencoded(data)}")
  dispatch(PageUsers)

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
  }

  init = [
    initState
    [runGetProviders]
    [runPageUsersHistory, indexOptionFromState(initState)]
  ]

  view = ({mode, users, providers, pagination, search, option, order}) ->
    html.div {}, [
      batchProccessing({mode, users, providers})
      if mode != 'upload'
        html.div {key: 'index-params'}, [
          searchForm {search..., onsearch: Search}
          indexGroupsOption {option..., onchange: ChangeOption}
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

  subscriptions = (state) ->
    if state.mode != 'upload'
      [[onPopstateSubscriber]]
    else
      []

  app {init, view, node, subscriptions}

main()