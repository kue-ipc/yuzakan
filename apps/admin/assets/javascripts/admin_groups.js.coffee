import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'
import {fetchJsonGet} from '../api/fetch_json.js'
import BsIcon from '../bs_icon.js'

pageAction = (state, {page}) ->
  newState = {state..., page}
  [
    newState
    [indexAllGroupsRunner, newState]
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

groupProviderTd = ({group, provider}) ->
  if group.providers.includes(provider.name)
    html.td {class: 'text-success'},
      BsIcon({name: 'check-square'})
  else
    html.td {class: 'text-muted'},
      BsIcon({name: 'square'})

groupTr = ({group, providers}) ->
  html.tr {}, [
    html.td {},
      html.a {href: "/admin/groups/#{group.name}"}, text group.name
    html.td {}, text group.display_name
    (groupProviderTd({group, provider}) for provider in providers)...
  ]

initAllGroupsAction = (state, {groups, total}) ->
  {state..., groups, total}

indexAllGroupsRunner = (dispatch, {page, per_page, query}) ->
  response = await fetchJsonGet({url: '/api/groups', data: {page, per_page, query}})
  if response.ok
    dispatch(initAllGroupsAction, {
      groups: response.data
      total: response.total
    })
  else
    console.error response

initAllProvidersAction = (state, {providers}) ->
  # providers group only
  {state..., providers: (provider for provider in providers when provider.group)}

indexAllProvidersRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/providers'})
  if response.ok
    dispatch(initAllProvidersAction, {providers: response.data})
  else
    console.error response

initState = {groups: [], providers: [], page: 1, per_page: 20, total: 0, query: ''}

init = [
  initState
  [indexAllProvidersRunner]
  [indexAllGroupsRunner, initState]
]

view = ({groups, providers, page, per_page, total, query}) ->
  html.div {}, [
    pagination({page, per_page, total})
    if query && total == 0
      html.p {}, text 'グループが存在しません。'
    else
      html.table {class: 'table'}, [
        html.thead {},
          html.tr {}, [
            html.th {}, text 'グループ名'
            html.th {}, text '表示名'
            (providerTh({provider}) for provider in providers)...
          ]
        html.tbody {}, (groupTr({group, providers}) for group in groups)
      ]
  ]

node = document.getElementById('admin_groups')

app {init, view, node}
