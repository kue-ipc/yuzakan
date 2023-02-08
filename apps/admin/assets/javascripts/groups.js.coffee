import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import BsIcon from '/assets/bs_icon.js'
import {pick, pickType} from '/assets/utils.js'
import {objToUrlencoded} from '/assets/form_helper.js'
import valueDisplay from '/assets/value_display.js'

import {runIndexWithPageGroups, INDEX_GROUPS_ALLOW_KEYS} from '/assets/api/groups.js'
import {runIndexProviders} from '/assets/api/providers.js'

import pagination from './pagination.js'
import search from './search.js'

providerTh = ({provider}) ->
  html.th {key: "provider[#{provider.name}]"}, text provider.label

groupProviderTd = ({group, provider}) ->
  html.td {key: "group[#{group.gropname}]"},
    valueDisplay {
      value: group.providers?.includes(provider.name)
      type: 'boolean'
    }

groupTr = ({group, providers}) ->
  html.tr {key: "group[#{group.gropname}]"}, [
    html.td {key: 'groupname'},
      html.a {href: "/admin/groups/#{group.groupname}"}, text group.groupname
    html.td {key: 'label'}, text group.label
    (groupProviderTd({group, provider}) for provider in providers)...
  ]

ReloadIndexGroups = (state, data) ->
  data = pickType(data, INDEX_GROUPS_ALLOW_KEYS)
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
  html.div {}, [
    pagination({page, per_page, total, onpage: MovePage})
    search({query, onsearch: Search})
    if query && total == 0
      html.p {}, text 'グループが存在しません。'
    else
      html.table {class: 'table'}, [
        html.thead {},
          html.tr {}, [
            html.th {key: 'groupname'}, text 'グループ名'
            html.th {key: 'label'}, text 'ラベル'
            (providerTh({provider}) for provider in providers)...
          ]
        html.tbody {}, (groupTr({group, providers}) for group in groups)
      ]
  ]

node = document.getElementById('groups')

app {init, view, node}
