import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import BsIcon from '/assets/bs_icon.js'
import {pick, pickType, toBoolean} from '/assets/utils.js'
import {objToUrlencoded} from '/assets/form_helper.js'
import valueDisplay from '/assets/value_display.js'

import {createRunIndexWithPageGroups, INDEX_GROUPS_PARAM_TYPES, GROUP_PROPERTIES} from '/assets/api/groups.js'
import {runIndexProviders} from '/assets/api/providers.js'

import pageNav from './page_nav.js'
import searchForm from './search_form.js'

# import {downloadButton, uploadButton} from './groups_csv.js'
import {downloadButton, uploadButton} from './csv.js'

# views

indexGroupsOption = ({onchange: action, props...}) ->
  onchange = (state, event) -> [action, {[event.target.name]: event.target.checked}]

  html.div {class: 'row mb-2'},
    for key, val of {
      sync: 'プロバイダーと同期'
      primary_only: 'プライマリーのみ'
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
            onchange: onchange
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

doAllActionButton = () ->
  html.button {
    class: 'btn btn-danger'
  }, text 'すべて実行'

# actions

ReloadIndexGroups = (state, data) ->
  console.debug 'reload index groups'
  newState = {state..., data...}
  params = {
    newState.page_info...
    newState.search...
    newState.option...
    order: newState.order
  }
  [
    newState,
    [runGroupHistory, params]
    [runLoadIndexGroups, params]
  ]

FinishIndexGroups = (state, groups) ->
  console.debug 'finish load groups'
  {
    state...
    mode: 'loaded'
    groups: ({action: '', group...} for group in groups)
  }

# effecters

runLoadIndexGroups = createRunIndexWithPageGroups({action: FinishIndexGroups})

runGroupHistory = (dispatch, params) ->
  params = pick(params, Object.keys(INDEX_GROUPS_PARAM_TYPES))
  query = "?#{objToUrlencoded(params)}"
  if (query != location.search)
    history.pushState(params, '', "/admin/groups?#{query}")

MovePage = (state, page) ->
  return state if state.page == page

  [ReloadIndexGroups, {page_info: {state.page_info... , page}}]

Search = (state, query) ->
  return state if state.query == query

  # ページ情報を初期化
  [ReloadIndexGroups, {page_info: {}, search: {query}}]

ChangeOption = (state, option) ->
  [ReloadIndexGroups, {option: {state.option..., option...}}]

SortOrder = (state, order) ->
  [ReloadIndexGroups, {order}]

UploadGroups = (state, {list, filename}) ->
  groups = for data in list
    {
      action: data.action?.toUpperCase()
      pickType(data, GROUP_PROPERTIES)...
      providers: (k for k, v of data.providers when toBoolean(v))
      label: data.display_name || data.groupname
    }

  {
    state...
    mode: 'upload'
    groups
  }

queryParams = pickType(Object.fromEntries(new URLSearchParams(location.search)))

initState = {
  mode: 'loading'
  groups: []
  providers: []
  total: 0
  page_info: pick(queryParams, ['page', 'per_page'])
  search: pick(queryParams, ['query'])
  option: pick(queryParams, ['sync', 'primary_only', 'show_deleted'])
  order: queryParams['order']
}

init = [
  initState
  [runIndexProviders, {has_groups: true}]
  [runLoadIndexGroups, pick(initState, Object.keys(INDEX_GROUPS_PARAM_TYPES))]
]

view = ({mode, groups, providers, page_info, search, option, order}) ->
  html.div {}, [
    if mode == 'upload'
      html.div {}, [
        html.div {class: 'mb-2'}, text 'アップロードモード'
        html.div {key: 'buttons', class: 'row mb-2'}, [
          html.div {class: 'col-md-3'}, doAllActionButton()
          html.div {class: 'col-md-3'}, downloadButton({list: groups, filename: 'result_groups.csv'})
        ]
      ]
    else
      html.div {}, [
        searchForm({search..., onsearch: Search})
        indexGroupsOption({option..., onchange: ChangeOption})
        html.div {key: 'buttons', class: 'row mb-2'}, [
          html.div {class: 'col-md-3'}, uploadButton({onupload: UploadGroups})
          html.div {class: 'col-md-3'}, downloadButton({list: groups, filename: 'groups.csv'})
        ]
        pageNav({page_info..., onpage: MovePage})
      ]
    if mode == 'loading'
      html.p {}, text '読込中...'
    else if groups.length == 0
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
