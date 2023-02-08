import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import BsIcon from '/assets/bs_icon.js'
import {pick, pickType} from '/assets/utils.js'
import {objToUrlencoded} from '/assets/form_helper.js'

import {runIndexWithPageGroups, INDEX_GROUPS_ALLOW_KEYS} from '/assets/api/groups.js'
import {runIndexProviders} from '/assets/api/providers.js'

import pagination from './pagination.js'
import search from './search.js'

pageAction = (state, {page}) ->
  newState = {state..., page}
  [
    newState
    [indexAllGroupsRunner, newState]
  ]

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

# pagination = ({page, per_page, total}) ->
#   first_page = 1
#   last_page = Math.floor(total / per_page) + 1

#   list = [
#     pageItem {content: '最初', page: first_page, disabled: page == first_page}
#     pageItem {content: '前', page: page - 1, disabled: page == first_page}
#     (pageItem {content: num, page: num, active: page == num} for num in [first_page..last_page])...
#     pageItem {content: '次', page: page + 1, disabled: page == last_page}
#     pageItem {content: '最後', page: last_page, disabled: page == last_page}
#   ]

#   html.nav {'aria-label': 'ページナビゲーション'},
#     html.ul {class: 'pagination'}, list

providerTh = ({provider}) ->
  html.th {}, text provider.label

groupProviderTd = ({group, provider}) ->
  if group.providers?
    if group.providers.includes(provider.name)
      html.td {class: 'text-success'},
        BsIcon({name: 'check-square'})
    else
      html.td {class: 'text-muted'},
        BsIcon({name: 'square'})
  else
    html.td {}

groupTr = ({group, providers}) ->
  html.tr {}, [
    html.td {},
      html.a {href: "/admin/groups/#{group.groupname}"}, text group.groupname
    html.td {}, text group.label
    (groupProviderTd({group, provider}) for provider in providers)...
  ]

ReloadIndexGroups = (state, data) ->
  data = pick(data, INDEX_GROUPS_ALLOW_KEYS)
  newState = {state..., data...}
  [
    newState,
    [runGroupHistory, data]
    [runIndexWithPageGroups, data]
  ]

runGroupHistory = (dispatch, data) ->
  query = "?#{objToUrlencoded(data)}"
  if (query != location.search)
    history.pushState(data, '', "/admin/groups?#{objToUrlencoded(data)}")

MovePage = (state, page) ->
  return state if state.page == page

  [ReloadIndexGroups, {page}]

Search = (state, query) ->
  return state if state.query == query

  # ページを初期化
  [ReloadIndexGroups, {page: 1, query}]

queryParams = Object.fromEntries(new URLSearchParams(location.search))

initState = {
  groups: [], providers: [], total: 0
  pickType(queryParams, INDEX_GROUPS_ALLOW_KEYS)...
}

init = [
  initState
  [runIndexProviders, {has_groups: true}]
  [runIndexWithPageGroups, pick(initState, INDEX_GROUPS_ALLOW_KEYS)]
]


view = ({groups, providers, page, per_page, total, query, params...}) ->
  console.log 'view'
  console.log {page, per_page, total, query, params...}
  html.div {}, [
    pagination({page, per_page, total, onpage: MovePage})
    search({query, onsearch: Search})
    if query && total == 0
      html.p {}, text 'グループが存在しません。'
    else
      html.table {class: 'table'}, [
        html.thead {},
          html.tr {}, [
            html.th {}, text 'グループ名'
            html.th {}, text '名前'
            (providerTh({provider}) for provider in providers)...
          ]
        html.tbody {}, (groupTr({group, providers}) for group in groups)
      ]
  ]

node = document.getElementById('groups')

app {init, view, node}
