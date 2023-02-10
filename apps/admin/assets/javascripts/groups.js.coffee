import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import BsIcon from '/assets/bs_icon.js'
import {pick, pickType} from '/assets/utils.js'
import {objToUrlencoded} from '/assets/form_helper.js'
import valueDisplay from '/assets/value_display.js'

import {runIndexWithPageGroups, INDEX_GROUPS_ALLOW_KEYS} from '/assets/api/groups.js'
import {runIndexProviders} from '/assets/api/providers.js'

import pageNav from './page_nav.js'
import search from './search.js'

GROUP_KEYS = [
  'groupname'
  'display_name'
  'note'
  'primary'
  'obsoleted'
  'deleted'
  'deleted_at'
  'providers'
]

valueToCsv = (value) ->
  switch value
    when null, undefined
      ''
    when true
      '1'
    when false
      '0'
    else
      '"' + String(value).replace(/"/g, '""') + '"'

createCsv = (groups) ->
  csv = []
  csv.push "\ufeffaction," + GROUP_KEYS.join(',') + "\r\n"
  for group in groups
    csv.push ',' + (valueToCsv(group[key]) for key in GROUP_KEYS).join(',') + "\r\n"
  csv

downloadCsv = ({groups})->
  return html.span {} unless groups?

  csv = createCsv(groups)
  blob = new Blob csv, {type: 'text/csv'}
  url = URL.createObjectURL(blob)
  html.a {
    class: 'btn btn-primary'
    href: url
    type: 'text/csv'
    download: 'groups.csv'
  }, text 'ダウンロード'

uploadCsv = () ->
  inputFile = html.input {class: 'form-control', type: 'file', accept: '.csv,text/csv'}
  html.div {class: 'input-group'}, [
    inputFile
    html.button {
      class: 'btn btn-primary'
      onclick: () -> [UploadCsv, inputFile.node.files]
    }, text 'アップロード'
  ]

runReadCsv = (dispatch, file) ->
  csv = await file.text()
  console.log csv

UploadCsv = (state, files) ->
  return state unless files?.length

  [state, [runReadCsv, files[0]]]


ChangeCondition = (state, event) ->
  [ReloadIndexGroups, {[event.target.name]: event.target.checked}]

condition = (props) ->
  html.div {class: 'row mb-2'},
    for key, val of {
      sync: 'プロバイダーと同期'
      primary_only: 'プライマリーのみ'
      show_deleted: '削除済みも表示'
    }
      id = "condition-#{key}"
      html.div {key: "condition[#{key}]", class: 'col-md-3'},
        html.div {class: 'form-check'}, [
          html.input {
            id
            class: 'form-check-input'
            name: key
            type: 'checkbox'
            checked: props[key]
            onchange: ChangeCondition
          }
          html.label {class: 'form-check-label', for: id}, text val
        ]


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
    html.td {key: 'action'},
      html.a {class: 'btn btn-sm btn-primary', href: "/admin/groups/#{group.groupname}"}, text '閲覧'
    html.td {key: 'groupname'}, text group.groupname
    html.td {key: 'label'}, text group.label
    (groupProviderTd({group, provider}) for provider in providers)...
  ]

ReloadIndexGroups = (state, data) ->
  data = pickType(data, INDEX_GROUPS_ALLOW_KEYS)
  newState = {state..., data...}
  [
    newState,
    [runGroupHistory, newState]
    [runIndexWithPageGroups, newState]
  ]

runGroupHistory = (dispatch, data) ->
  data = pick(data, Object.keys(INDEX_GROUPS_ALLOW_KEYS))
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
  [runIndexWithPageGroups, pick(initState, Object.keys(INDEX_GROUPS_ALLOW_KEYS))]
]

view = ({groups, providers, page, per_page, total, start, end, query, sync, primary_only, show_deleted}) ->
  html.div {}, [
    search({query, onsearch: Search})
    condition({sync, primary_only, show_deleted})
    html.div {class: 'row mb-2'}, [
      html.div {class: 'col-md-3'}, downloadCsv({groups})
      html.div {class: 'col-md-6'}, uploadCsv()
    ]
    pageNav({page, per_page, total, start, end, onpage: MovePage})
    if query && total == 0
      html.p {}, text 'グループが存在しません。'
    else
      html.table {class: 'table'}, [
        html.thead {},
          html.tr {}, [
            html.th {key: 'action'}, text 'アクション'
            html.th {key: 'groupname'}, text 'グループ名'
            html.th {key: 'label'}, text 'ラベル'
            (providerTh({provider}) for provider in providers)...
          ]
        html.tbody {}, (groupTr({group, providers}) for group in groups)
      ]
  ]

node = document.getElementById('groups')

app {init, view, node}
