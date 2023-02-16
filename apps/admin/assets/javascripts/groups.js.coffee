import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import BsIcon from '/assets/bs_icon.js'
import {pick, pickType, toBoolean, updateList, getQueryParamsFromUrl} from '/assets/utils.js'
import {objToUrlencoded} from '/assets/form_helper.js'
import valueDisplay from '/assets/value_display.js'
import ConfirmDialog from '/assets/confirm_dialog.js'
import {fieldId} from '/assets/form_helper.js'

import {
  INDEX_WITH_PAGE_GROUPS_PARAM_TYPES, GROUP_PROPERTIES
  normalizeGroup
  createRunIndexWithPageGroups, createRunUpdateGroup
} from '/assets/api/groups.js'
import {createRunIndexProviders} from '/assets/api/providers.js'


import pageNav from './page_nav.js'
import searchForm from './search_form.js'

import {downloadButton, uploadButton} from './csv.js'

# Functions

updateGroupList = (group, groups) -> updateList(group, groups, 'groupname')

normalizeGroupExpand = (group) -> normalizeGroup(group, {
  action: 'string'
  label: 'string'
  show_detail: 'boolean'
  error: 'any'
})

# dialog

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
  html.th {key: "provider[#{provider.name}]"}, text provider.label

groupProviderTd = ({group, provider}) ->
  html.td {key: "group[#{group.groupname}]"},
    valueDisplay {
      value: group.providers?.includes(provider.name)
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
    key: "group[#{group.groupname}]"
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
          html.a {href: "/admin/groups/#{group.groupname}"}, text '閲覧'
    html.td {key: 'groupname'}, text group.groupname
    html.td {key: 'label'}, [
      html.span {}, text group.label
      html.span {class: 'ms-2 badge text-bg-primary'}, text 'プライマリー' if group.primary
      html.span {class: 'ms-2 badge text-bg-warning'}, text '使用禁止' if group.prohibited
      html.span {class: 'ms-2 badge text-bg-danger'}, text '削除済み' if group.deleted
    ]
    (groupProviderTd({group, provider}) for provider in providers)...
  ]

groupDetailTr = ({group, colspan}) ->
  html.tr {
    key: "group-detail[#{group.groupname}]"
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

doAllActionButton = () ->
  html.button {
    class: 'btn btn-danger'
    onclick: DoAllActionWithConfirm
  }, text 'すべて実行'

# Actions

SetGroupInList = (state, group) ->
  {
    state...
    groups: updateGroupList(normalizeGroupExpand(group), state.groups)
  }

ModGroup = (state, group) ->
  action = (_, data) ->
    [SetGroupInList, {group..., data..., action: 'SUC', error: null}]
  fallback = (_, error) ->
    [SetGroupInList, {group..., action: 'ERR', error, show_detail: true}]
  run = createRunUpdateGroup({action, fallback})
  [
    {state..., groups: updateGroupList({group..., action: 'ACT'}, state.groups)}
    [run, {group..., id: group.groupname}]
  ]

ReloadIndexGroups = (state, data) ->
  console.debug 'reload index groups'
  newState = {state..., data...}
  params = pick({
    newState.paginitaion...
    newState.search...
    newState.option...
    order: newState.order
  }, Object.keys(INDEX_WITH_PAGE_GROUPS_PARAM_TYPES))
  [
    newState,
    [runPushHistory, params]
    [runIndexGroups, params]
  ]

SetIndexGroups = (state, rawGroups) ->
  console.debug 'finish load groups'
  groups = for group in rawGroups
    normalizeGroupExpand({
      group...
      action: ''
      show_detail: false
      error: null
    })
  {
    state...
    mode: 'loaded'
    groups
  }

MovePage = (state, page) ->
  return state if state.page == page

  [ReloadIndexGroups, {paginitaion: {state.paginitaion... , page}}]

Search = (state, query) ->
  return state if state.query == query

  # ページ情報を初期化
  [ReloadIndexGroups, {paginitaion: {}, search: {query}}]

ChangeOption = (state, option) ->
  # ページ情報を初期化
  [ReloadIndexGroups, {paginitaion: {}, option: {state.option..., option...}}]

SortOrder = (state, order) ->
  [ReloadIndexGroups, {order}]

UploadGroups = (state, {list, filename}) ->
  groups = for group in list
    normalizeGroupExpand({
      group...
      action: group.action?.toUpperCase()
      label: group.display_name || group.groupname
      show_detail: false
      error: null
    })
  {
    state...
    mode: 'upload'
    groups
  }

DoAllActionWithConfirm = (state) ->
  [state, runDoAllActionWithConfirm]

SetGroupInListNextAll = (state, group) ->
  [
    {
      state...
      groups: updateGroupList(group, state.groups)
    }
    runDoAllAction
  ]

ModGroupNextAll = (state, group) ->
  action = (_, data) ->
    [SetGroupInListNextAll, {group..., data..., action: 'SUC', error: null}]
  fallback = (_, error) ->
    [SetGroupInListNextAll, {group..., action: 'ERR', error, show_detail: true}]
  run = createRunUpdateGroup({action, fallback})
  [
    {state..., groups: updateGroupList({group..., action: 'ACT'}, state.groups)}
    [run, {group..., id: group.groupname}]
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
  queryParams = pickType(getQueryParamsFromUrl(location), INDEX_WITH_PAGE_GROUPS_PARAM_TYPES)

  initState = {
    mode: 'loading'
    groups: []
    providers: []
    paginitaion: pick(queryParams, ['page', 'per_page'])
    search: pick(queryParams, ['query'])
    option: pick(queryParams, ['sync', 'primary_only', 'show_deleted'])
    order: queryParams['order']
  }

  init = [
    initState
    [runIndexProviders, {has_groups: true}]
    [runIndexGroups, pick(initState, Object.keys(INDEX_WITH_PAGE_GROUPS_PARAM_TYPES))]
  ]

  view = ({mode, groups, providers, paginiation, search, option, order}) ->
    html.div {}, [
      if mode == 'upload'
        html.div {}, [
          html.div {class: 'mb-2'}, text 'アップロードモード'
          html.div {key: 'buttons', class: 'row mb-2'}, [
            html.div {key: 'upload', class: 'col-md-3'},
              uploadButton {onupload: UploadGroups, disabled: true}
            html.div {key: 'download', class: 'col-md-3'},
              # アップロードモードではヘッダを指定しない
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
          pageNav {paginiation..., onpage: MovePage}
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

main()