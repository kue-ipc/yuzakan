import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'
import {fetchJsonGet} from '../fetch_json.js'
import BsIcon from '../bs_icon.js'

searchAction = (state, {query}) ->
  return state if state.query == query

  # ページを初期化
  newState = {state..., page: 1, query}
  [
    newState
    [indexAllUsersRunner, newState]
  ]

search = ({query}) ->
  searchInput = html.input {
    class: 'form-control'
    type: 'search'
    placeholder: '検索...'
    onkeypress: (state, event) ->
      if event.keyCode == 13
        [searchAction, {query: event.target.value}]
      else
        state
  }

  html.div {class: 'row mb-3'}, [
    html.div {class: 'col-md-3'},
      html.div {class: 'input-group'}, [
        searchInput
        html.button {
          type: 'button'
          class: 'btn btn-outline-secondary'
          onclick: (state) -> [searchAction, {query: searchInput.node.value}]
        }, BsIcon({name: 'search'})
      ]
    html.div {class: 'col-md-3'},
      html.input {
        id: 'search-query'
        type: 'text'
        class: 'form-control-plaintext'
        value: query
      }
  ]

pageAction = (state, {page}) ->
  newState = {state..., page}
  [
    newState
    [indexAllUsersRunner, newState]
  ]

pageItem = ({content, page, active = false, disabled = false}) ->
  liClass = ['page-item']
  liClass.push 'active' if active
  liClass.push 'disabled' if disabled
  html.li {class: liClass},
    html.button {
      type: 'button'
      class: 'page-link'
      onclick: (state) -> [pageAction, {page: page}]
    }, text content

pageEllipsis = ({content = '...'}) ->
  liClass = ['page-item', 'disabled']
  html.li {class: liClass},
    html.span {class: 'page-link'}, text content

pagination = ({page, per_page, total}) ->
  first_page = 1
  last_page = Math.floor(total / per_page) + 1
  total_page = last_page - first_page + 1

  list = []
  list.push(pageItem {content: '最初', page: first_page, disabled: page == first_page})
  list.push(pageItem {content: '前', page: page - 1, disabled: page == first_page})

  if last_page <= 5
    list.push(pageItem {content: num, page: num, active: page == num}) for num in [first_page..last_page]
  else if page <= 3
    list.push(pageItem {content: num, page: num, active: page == num}) for num in [first_page..5]
    list.push(pageEllipsis {})
  else if last_page - page <= 2
    list.push(pageEllipsis {})
    list.push(pageItem {content: num, page: num, active: page == num}) for num in [(last_page - 4)..last_page]
  else
    list.push(pageEllipsis {})
    list.push(pageItem {content: num, page: num, active: page == num}) for num in [(page - 2)..(page + 2)]
    list.push(pageEllipsis {})

  list.push(pageItem {content: '次', page: page + 1, disabled: page == last_page})
  list.push(pageItem {content: '最後', page: last_page, disabled: page == last_page})

  html.nav {class: 'd-flex', 'aria-label': 'ページナビゲーション'}, [
    html.ul {class: 'pagination'}, list
    html.p {class: 'ms-2 mt-2'},
      text "#{(page - 1) * per_page + 1} - #{Math.min(page * per_page, total)} / #{total} ユーザー"
  ]

providerTh = ({provider}) ->
  html.th {}, text provider.label

userProviderTd = ({user, provider}) ->
  if user.providers.includes(provider.name)
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

initAllUsersAction = (state, {users, total}) ->
  {state..., users, total}

indexAllUsersRunner = (dispatch, {page, per_page, query}) ->
  response = await fetchJsonGet({url: '/api/users', data: {page, per_page, query}})
  if response.ok
    dispatch(initAllUsersAction, {
      users: response.data
      total: response.total
    })
  else
    console.error response

initAllProvidersAction = (state, {providers}) ->
  {state..., providers}

indexAllProvidersRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/providers'})
  if response.ok
    dispatch(initAllProvidersAction, {providers: response.data})
  else
    console.error response

initState = {users: [], providers: [], page: 1, per_page: 20, total: 0, query: ''}

init = [
  initState
  [indexAllProvidersRunner]
  [indexAllUsersRunner, initState]
]

view = ({users, providers, page, per_page, total, query}) ->
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

node = document.getElementById('admin_users')

app {init, view, node}
