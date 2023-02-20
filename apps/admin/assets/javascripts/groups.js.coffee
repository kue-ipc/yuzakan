import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import BsIcon from '/assets/bs_icon.js'
import {pick, pickType, updateList, getQueryParamsFromUrl, entityLabel} from '/assets/utils.js'
import {objToUrlencoded} from '/assets/form_helper.js'
import valueDisplay from '/assets/value_display.js'
import ConfirmDialog from '/assets/confirm_dialog.js'
import {fieldId} from '/assets/form_helper.js'

import {
  INDEX_GROUPS_OPTION_PARAM_TYPES
  INDEX_WITH_PAGE_GROUPS_PARAM_TYPES, GROUP_PROPERTIES
  normalizeGroup
  createRunIndexWithPageGroups, createRunUpdateGroup
} from '/assets/api/groups.js'
import {createRunIndexProviders} from '/assets/api/providers.js'
import {PAGINATION_PARAM_TYPES} from '/assets/api/pagination.js'
import {SEARCH_PARAM_TYPES} from '/assets/api/search.js'
import {ORDER_PARAM_TYPES} from '/assets/api/order.js'

import pageNav from './page_nav.js'
import searchForm from './search_form.js'
import {downloadButton, uploadButton} from './csv.js'

# Functions

updateGroupList = (group, groups) -> updateList(group, groups, 'name')

normalizeGroupUploaded = ({action, error, group...}) ->
  action = action?.slice(0, 3)?.toUpperCase() ? ''
  error = switch action
    when '', 'MOD'
      null
    when 'ADD', 'DEL'
      'この処理は対応していません。'
    when 'ERR', 'SUC', 'ACT'
      error
    else
      action = 'ERR'
      '指定した処理が不正です。'
  {
    action
    error
    normalizeGroup(group)...
  }

indexOptionFromState = (state) ->
  pick({
    state.pagination...
    state.search...
    state.option...
    state.order...
  }, Object.keys(INDEX_WITH_PAGE_GROUPS_PARAM_TYPES))

# Dialogs

doAllActionConfirm = new ConfirmDialog {
  id: fieldId('do_all_action', ['modal', 'confirm', 'group'])
  states: 'alert'
  title: 'すべて実行'
  action: {
    color: 'danger'
    label: 'すべて実行'
  }
}

# Views

indexGroupsOption = ({onchange: action, props...}) ->
  onchange = (state, event) -> [action, {[event.target.name]: event.target.checked}]

  html.div {class: 'row mb-2'},
    for key, val of {
      sync: 'プロバイダーと同期'
      primary_only: 'プライマリーのみ'
      hide_prohibited: '使用禁止を隠す'
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
  html.th {key: "provider[#{provider.name}]"}, text entityLabel(provider)

groupProviderTd = ({group, provider}) ->
  html.td {key: "group[#{group.name}]"},
    valueDisplay {
      value: group.providers?.get(provider.name)
      type: 'boolean'
    }

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
    key: "group[#{group.name}]"
    class: "table-#{color}"
  }, [
    html.td {
      key: 'show'
      onclick: -> [SetGroupInList, {group..., show_detail: !group.show_detail}]
    },
      if group.show_detail
        BsIcon {name: 'chevron-down'}
      else
        BsIcon {name: 'chevron-right'}
    html.td {key: 'action'},
      switch group.action
        when 'ACT'
          html.div {class: 'spinner-border spinner-border-sm', role: 'status'},
            html.span {class: 'visually-hidden'}, text '実行中'
        when 'MOD'
          html.button {
            class: 'btn btn-sm btn-info'
            onclick: -> [ModGroup, group]
          }, text '変更'
        when 'ERR'
          html.div {}, text 'エラー'
        else
          html.a {href: "/admin/groups/#{group.name}"}, text '閲覧'
    html.td {key: 'name'}, text group.name
    html.td {key: 'label'}, [
      html.span {}, text entityLabel(group)
      html.span {class: 'ms-2 badge text-bg-primary'}, text 'プライマリー' if group.primary
      html.span {class: 'ms-2 badge text-bg-warning'}, text '使用禁止' if group.prohibited
      html.span {class: 'ms-2 badge text-bg-danger'}, text '削除済み' if group.deleted
    ]
    (groupProviderTd({group, provider}) for provider in providers)...
  ]

groupDetailTr = ({group, colspan}) ->
  html.tr {
    key: "group-detail[#{group.name}]"
    class: {collapse: true, show: group.show_detail}
  },
    html.td {colspan}, [
      html.div {key: 'properties'}, [
        html.span {}, text "表示名: #{group.display_name || '(無し)'}"
        html.span {class: 'ms-2'}, text "削除日: #{group.deleted_at}" if group.deleted_at
      ]
      if group.note
        html.div {key: 'note'},
          html.pre {class: 'mb-0 text-info'}, text group.note
      if group.error
        html.div {key: 'error'},
          html.pre {class: 'mb-0 text-danger'},
            text if typeof group.error == 'string'
              group.error
            else
              JSON.stringify(group.error, null, 2)
    ]

batchProccessing = ({mode, groups, providers}) ->
  filename = if mode == 'upload'
    'result_groups.csv'
  else
    'groups.csv'
  headers = [
    'action'
    Object.keys(GROUP_PROPERTIES)...
    ("provider[#{provider.name}]" for provider in providers)...
    'error'
  ]

  html.div {key: 'batch-processing', class: 'row mb-2'}, [
    html.div {key: 'upload', class: 'col-md-3'},
      uploadButton {onupload: UploadGroups, disabled: mode == 'upload'}
    html.div {key: 'download', class: 'col-md-3'},
      downloadButton {
        list: groups
        filename
        headers
        disabled: mode == 'loading'
      }
    html.div {key: 'do_all_action', class: 'col-md-3'},
      doAllActionButton {} if mode == 'upload'
  ]

doAllActionButton = () ->
  html.button {
    class: 'btn btn-danger'
    onclick: DoAllActionWithConfirm
  }, text 'すべて実行'

# Actions

ReloadIndexGroups = (state, data) ->
  console.debug 'reload index groups'
  newState = {state..., data..., mode: 'loading'}
  params = indexOptionFromState(newState)
  [
    newState,
    [runPushHistory, params]
    [runIndexGroups, params]
  ]

SetIndexGroups = (state, rawGroups) ->
  console.debug 'finish load groups'
  groups = for group in rawGroups
    {
      action: ''
      show_detail: false
      error: null
      group...
    }
  {
    state...
    mode: 'loaded'
    groups
  }

MovePage = (state, page) ->
  return state if state.page == page

  [ReloadIndexGroups, {pagination: {state.pagination... , page}}]

Search = (state, query) ->
  return state if state.query == query

  # ページ情報を初期化
  [ReloadIndexGroups, {pagination: {state.pagination... , page: 1}, search: {query}}]

ChangeOption = (state, option) ->
  # ページ情報を初期化
  [ReloadIndexGroups, {pagination: {state.pagination... , page: 1}, option: {state.option..., option...}}]

SortOrder = (state, order) ->
  [ReloadIndexGroups, {order}]

UploadGroups = (state, {list, filename}) ->
  groups = for group in list
    {
      show_detail: false
      normalizeGroupUploaded(group)...
    }
  {
    state...
    mode: 'upload'
    groups
  }

DoAllActionWithConfirm = (state) ->
  [state, runDoAllActionWithConfirm]

SetGroupInList = (state, group) ->
  {
    state...
    groups: updateGroupList(group, state.groups)
  }

SetGroupInListNextAll = (state, group) ->
  [
    {
      state...
      groups: updateGroupList(group, state.groups)
    }
    runDoAllAction
  ]

ModGroup = (state, group) ->
  action = (_, data) ->
    if data?
      [SetGroupInList, {group..., data..., action: 'SUC', error: null}]
    else
      [SetGroupInList, {group..., action: 'ERR', error: '存在しません。'}]
  fallback = (_, error) ->
    [SetGroupInList, {group..., action: 'ERR', error, show_detail: true}]
  run = createRunUpdateGroup({action, fallback})
  [
    {state..., groups: updateGroupList({group..., action: 'ACT'}, state.groups)}
    [run, {group..., id: group.name}]
  ]

ModGroupNextAll = (state, group) ->
  action = (_, data) ->
    if data?
      [SetGroupInListNextAll, {group..., data..., action: 'SUC', error: null}]
    else
      [SetGroupInList, {group..., action: 'ERR', error: '存在しません。'}]
  fallback = (_, error) ->
    [SetGroupInList, {group..., action: 'ERR', error, show_detail: true}]
  run = createRunUpdateGroup({action, fallback})
  [
    {state..., groups: updateGroupList({group..., action: 'ACT'}, state.groups)}
    [run, {group..., id: group.name}]
  ]

DoAllAction = (state) ->
  doActionGroup = state.groups.find (group) -> group.action == 'MOD'
  if doActionGroup
    [ModGroupNextAll, doActionGroup]
  else
    state

# Effecters

runIndexProviders = createRunIndexProviders()

runIndexGroups = createRunIndexWithPageGroups({action: SetIndexGroups})

runPushHistory = (dispatch, params) ->
  query = "?#{objToUrlencoded(params)}"
  if (query != location.search)
    history.pushState(params, '', "#{location.pathname}#{query}")

runDoAllActionWithConfirm = (dispatch) ->
  confirm = await doAllActionConfirm.showPromise({
    messages: [
      'すべての処理を実行します。'
      '処理は途中で停止することはできません。'
      'ブラウザーを閉じると処理が中断されます。決して、閉じないでください。'
      '予期せぬ中断を避けるために、スリープは無効にしておいてください。'
      'すべての処理を実行してもよろしいですか？']
  })
  if confirm
    dispatch(DoAllAction)

runDoAllAction = (dispatch) ->
  dispatch(DoAllAction)

# main

main = ->
  queryParams = getQueryParamsFromUrl(location)

  initState = {
    mode: 'loading'
    groups: []
    providers: []
    pagination: pickType(queryParams, PAGINATION_PARAM_TYPES)
    search: pickType(queryParams, SEARCH_PARAM_TYPES)
    option: pickType(queryParams, INDEX_GROUPS_OPTION_PARAM_TYPES)
    order: pickType(queryParams, ORDER_PARAM_TYPES)
  }

  init = [
    initState
    [runIndexProviders, {has_groups: true}]
    [runIndexGroups, indexOptionFromState(initState)]
  ]

  view = ({mode, groups, providers, pagination, search, option, order}) ->
    html.div {}, [
      batchProccessing({mode, groups, providers})
      if mode != 'upload'
        html.div {key: 'index-params'}, [
          searchForm {search..., onsearch: Search}
          indexGroupsOption {option..., onchange: ChangeOption}
          pageNav {pagination..., onpage: MovePage}
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
              html.th {key: 'name'}, text 'グループ名'
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

main()