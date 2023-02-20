import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import BsIcon from '/assets/bs_icon.js'
import {objToUrlencoded} from '/assets/form_helper.js'

import {
  INDEX_WITH_PAGE_USRERS_PARAM_TYPES, USER_PROPERTIES
  normalizeGroup
  createRunIndexWithPageUser
  createRunShowUser, createRunCreatUser, createRunUpdateUser, createRunDestroyUser
} from '/assets/api/users.js'
import {createRunIndexProviders} from '/assets/api/providers.js'

import pageNav from './page_nav.js'
import searchForm from './search_form.js'
import {downloadButton, uploadButton} from './csv.js'


# searchAction = (state, {query}) ->
#   return state if state.query == query

#   # ページを初期化
#   newState = {state..., page: 1, query}
#   [
#     newState
#     [runPageUsersHistory, newState]
#   ]

# search = ({query}) ->
#   searchInput = html.input {
#     class: 'form-control'
#     type: 'search'
#     placeholder: '検索...'
#     onkeypress: (state, event) ->
#       if event.keyCode == 13
#         [searchAction, {query: event.target.value}]
#       else
#         state
#   }

#   html.div {class: 'row mb-3'}, [
#     html.div {class: 'col-md-3'},
#       html.div {class: 'input-group'}, [
#         searchInput
#         html.button {
#           type: 'button'
#           class: 'btn btn-outline-secondary'
#           onclick: (state) -> [searchAction, {query: searchInput.node.value}]
#         }, BsIcon({name: 'search'})
#       ]
#     html.div {class: 'col-md-3'},
#       html.input {
#         id: 'search-query'
#         type: 'text'
#         class: 'form-control-plaintext'
#         value: query
#       }
#   ]

# pageAction = (state, props) ->
#   newState = {state..., props...}
#   [
#     newState
#     [runPageUsersHistory, newState]
#   ]

# pageItem = ({content, page, active = false, disabled = false}) ->
#   liClass = ['page-item']
#   liClass.push 'active' if active
#   liClass.push 'disabled' if disabled
#   html.li {class: liClass},
#     html.button {
#       type: 'button'
#       class: 'page-link'
#       onclick: (state) -> [pageAction, {page: page}]
#     }, text content

# pageEllipsis = ({content = '...'}) ->
#   liClass = ['page-item', 'disabled']
#   html.li {class: liClass},
#     html.span {class: 'page-link'}, text content

# pagination = ({page, per_page, total}) ->
#   first_page = 1
#   last_page = Math.floor(total / per_page) + 1
#   total_page = last_page - first_page + 1

#   list = []
#   list.push(pageItem {content: '最初', page: first_page, disabled: page == first_page})
#   list.push(pageItem {content: '前', page: page - 1, disabled: page == first_page})

#   if last_page <= 5
#     list.push(pageItem {content: num, page: num, active: page == num}) for num in [first_page..last_page]
#   else if page <= 3
#     list.push(pageItem {content: num, page: num, active: page == num}) for num in [first_page..5]
#     list.push(pageEllipsis {})
#   else if last_page - page <= 2
#     list.push(pageEllipsis {})
#     list.push(pageItem {content: num, page: num, active: page == num}) for num in [(last_page - 4)..last_page]
#   else
#     list.push(pageEllipsis {})
#     list.push(pageItem {content: num, page: num, active: page == num}) for num in [(page - 2)..(page + 2)]
#     list.push(pageEllipsis {})

#   list.push(pageItem {content: '次', page: page + 1, disabled: page == last_page})
#   list.push(pageItem {content: '最後', page: last_page, disabled: page == last_page})

#   html.nav {class: 'd-flex', 'aria-label': 'ページナビゲーション'}, [
#     html.ul {class: 'pagination'}, list
#     html.p {class: 'ms-2 mt-2'},
#       text "#{(page - 1) * per_page + 1} - #{Math.min(page * per_page, total)} / #{total} ユーザー"
#   ]

# Functions

updateUserList = (user, users) -> updateList(user, users, 'name')

normalizeUserUploaded = ({action, user...}) ->
  action = action?.slice(0, 3)?.toUpperCase() ? ''
  error = switch action
    when '', 'ADD', 'MOD', 'DEL'
      null
    when 'LOC', 'UNL', 'RES'
      'この処理は対応していません。'
    when 'ERR', 'SUC', 'ACT'
      '処理中または処理済みです。'
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
      search({query})
      pagination({page, per_page, total})
      if query && total == 0
        html.p {}, text '該当するユーザーはいません。'
      else
        html.table {class: 'table'}, [
          html.thead {},
            html.tr {}, [
              html.th {}, text 'ユーザー名'
              html.th {}, text '表示名'
              html.th {}, text 'メールアドレス'
              html.th {}, text '権限レベル'
              (providerTh({provider}) for provider in providers)...
            ]
          html.tbody {}, (userTr({user, providers}) for user in users)
        ]
    ]

  node = document.getElementById('users')

  onPopstateSubscriber = (dispatch) ->
    window.addEventListener 'popstate', (event) ->
      dispatch(pageAction, event.state)

  onPopstate = ->
    [onPopstateSubscriber]

  subscriptions = (state) -> [
    onPopstate()
  ]

  app {init, view, node, subscriptions}

main()