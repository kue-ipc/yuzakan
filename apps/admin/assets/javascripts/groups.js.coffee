import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'
import {Collapse} from '/assets/vendor/bootstrap.js'

import BsIcon from '/assets/bs_icon.js'
import {pick, pickType, toBoolean, updateList} from '/assets/utils.js'
import {objToUrlencoded} from '/assets/form_helper.js'
import valueDisplay from '/assets/value_display.js'

import {
  createRunIndexWithPageGroups, createRunUpdateGroup
  INDEX_GROUPS_PARAM_TYPES, GROUP_PROPERTIES
} from '/assets/api/groups.js'
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
  html.td {key: "group[#{group.groupname}]"},
    valueDisplay {
      value: group.providers?.includes(provider.name)
      type: 'boolean'
    }

SetGroupInList = (state, group) ->
  {
    state...
    groups: updateGroupList(group, state.groups)
  }

updateGroupList = (group, groups) -> updateList(group, groups, 'groupname')

SetGroupInListOk = (state, group) ->
  [SetGroupInList, {group..., action: 'SUC'}]

ModGroup = (state, group) ->
  fallback = (state, error) ->
    [SetGroupInList, {group..., action: 'ERR', error}]
  run = createRunUpdateGroup({action: SetGroupInListOk, fallback})
  [
    {state..., groups: updateGroupList({group..., action: 'ACT'}, state.groups)}
    [run, {group..., id: group.groupname}]
  ]

groupTr = ({group, providers}) ->
  color = switch group.action
    when 'ADD'
      'primary'
    when 'MOD'
      'info'
    when 'DEL'
      'waring'
    when 'ERR'
      'danger'
    when 'SUC'
      'success'
    when 'ACT'
      'secondary'
    else
      'light'
  html.tr {
    key: "group[#{group.groupname}]"
    class: ["table-#{color}"]
    onclick: -> [SetGroupInList, {group..., show_detail: !group.show_detail}]
  }, [
    html.td {key: 'show'},
      if group.show_detail
        BsIcon {name: 'chevron-down'}
      else
        BsIcon {name: 'chevron-right'}
    html.td {key: 'action'},
      switch group.action
        when 'ACT'
          html.div {class: 'spinner-border', role: 'status'},
            html.span {class: 'visually-hidden'}, text: '実行中'
        when 'MOD'
          html.button {
            class: 'btn btn-sm btn-info'
            onclick: -> [ModGroup, group]
          }, text '変更'
        when 'ERR'
          html.div {}, text 'エラー'
        else
          html.a {href: "/admin/groups/#{group.groupname}"}, text '閲覧'
    html.td {key: 'groupname'}, text group.groupname
    html.td {key: 'label'}, text group.label
    (groupProviderTd({group, provider}) for provider in providers)...
  ]

groupDetailTr = ({group, colspan}) ->
  html.tr {
    key: "group-detail[#{group.groupname}]"
    class: {collapse: true, show: group.show_detail}
  }, [
    html.td {colspan}, text JSON.stringify(group)
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
    history.pushState(params, '', "/admin/groups#{query}")

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
          html.div {key: 'upload', class: 'col-md-3'},
            uploadButton {onupload: UploadGroups, disabled: true}
          html.div {key: 'download', class: 'col-md-3'},
            downloadButton {list: groups, filename: 'result_groups.csv'}
          html.div {key: 'do_all_action', class: 'col-md-3'},
            doAllActionButton {}
        ]
      ]
    else
      headers = [
        'action'
        Object.keys(GROUP_PROPERTIES)...
        ("provider[#{provider.name}]" for provider in providers)...
      ]
      html.div {}, [
        searchForm {search..., onsearch: Search}
        indexGroupsOption {option..., onchange: ChangeOption}
        html.div {key: 'buttons', class: 'row mb-2'}, [
          html.div {key: 'upload', class: 'col-md-3'},
            uploadButton {onupload: UploadGroups}
          html.div {key: 'downolad', class: 'col-md-3'},
            downloadButton {list: groups, filename: 'groups.csv', headers, disabled: mode == 'loading'}
        ]
        pageNav {page_info..., onpage: MovePage}
      ]
    if mode == 'loading'
      html.p {}, text '読込中...'
    else if groups.length == 0
      html.p {}, text 'グループが存在しません。'
    else
      html.table {id: 'group-table', class: 'table'}, [
        html.thead {},
          html.tr {}, [
            html.th {key: 'show'}, text ''
            html.th {key: 'action'}, text 'アクション'
            html.th {key: 'groupname'}, text 'グループ名'
            html.th {key: 'label'}, text 'ラベル'
            (providerTh({provider}) for provider in providers)...
          ]
        html.tbody {},
          (for group in groups
            [
              groupTr({group, providers})
              groupDetailTr({group, colspan: 4 + providers.length})
            ]
          ).flat()
      ]
  ]

node = document.getElementById('groups')

app {init, view, node}
