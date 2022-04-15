import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'
import {fetchJsonGet} from '../fetch_json.js'
import BsIcon from '../bs_icon.js'

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
      class: 'page-link'
      onclick: (state) -> [pageAction, {page: page}]
    }, text content

pagination = ({page, per_page, total}) ->
  first_page = 1
  last_page = Math.floor(total / per_page) + 1

  list = [
    pageItem {content: '最初', page: first_page, disabled: page == first_page}
    pageItem {content: '前', page: page - 1, disabled: page == first_page}
    (pageItem {content: num, page: num, active: page == num} for num in [first_page..last_page])...
    pageItem {content: '次', page: page + 1, disabled: page == last_page}
    pageItem {content: '最後', page: last_page, disabled: page == last_page}
  ]

  html.nav {'aria-label': 'ページナビゲーション'},
    html.ul {class: 'pagination'}, list

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
    # query({query})
    pagination({page, per_page, total})
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
