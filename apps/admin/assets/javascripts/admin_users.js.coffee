import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'
import {fetchJsonGet} from '../fetch_json.js'
import BsIcon from '../bs_icon.js'

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

initAllUsersAction = (state, {users}) ->
  {state..., users}

indexAllUsersRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/users'})
  console.log response
  if response.ok
    dispatch(initAllUsersAction, {users: response.data})
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

init = [
  {users: [], providers: []}
  [indexAllProvidersRunner]
  [indexAllUsersRunner]
]

view = ({users, providers}) ->
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

node = document.getElementById('admin_users')

app {init, view, node}
