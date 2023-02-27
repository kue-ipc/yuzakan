# /admin/gorups

import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import BsIcon from '/assets/app/bs_icon.js'
import {pick, pickType, getQueryParamsFromUrl, entityLabel} from '/assets/common/helper.js'
import {objToUrlencoded, listToParamName} from '/assets/common/convert.js'
import valueDisplay from '/assets/app/value_display.js'
import {updateList} from '/assets/common/list_helper.js'

import {
  GROUP_PROPERTIES, GROUP_DATA_PROPERTIES,
  INDEX_GROUPS_OPTION_PARAM_TYPES, INDEX_WITH_PAGE_GROUPS_PARAM_TYPES,
  normalizeGroup
  createRunIndexWithPageGroups, createRunShowGroup, createRunUpdateGroup
} from '/assets/api/groups.js'
import {createRunIndexProviders} from '/assets/api/providers.js'
import {PAGINATION_PARAM_TYPES} from '/assets/api/pagination.js'
import {SEARCH_PARAM_TYPES} from '/assets/api/search.js'
import {ORDER_PARAM_TYPES} from '/assets/api/order.js'

import pageNav from './page_nav.js'
import searchForm from './search_form.js'
import {batchOperation, runDoNextAction, runStopAllAction} from './batch_operation.js'

# mode
#   loading: 読込中
#   loaded: 読込完了
#   file: アップロードされたファイル
#   do_all: 全て実行中
#   result: 実行結果(全てとは限らない)

# Cnostants

GROUP_HEADERS = [
  'action'
  Object.keys(GROUP_PROPERTIES)...
]

ACTIONS = new Map([
  ['ADD', '追加']
  ['MOD', '変更']
  ['DEL', '削除']
  ['ERR', 'エラー']
  ['SUC', '成功']
  ['ACT', '実行中']
  ['SYN', '同期']
])

# Functions

updateGroupList = (groups, group) -> updateList(groups, group.name, group, {key: 'name'})

normalizeGroupUploaded = ({action, error, group...}) ->
  action = action?.slice(0, 3)?.toUpperCase() ? ''
  error = switch action
    when '', 'MOD', 'SYN'
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


# Views

indexGroupsOption = ({onchange: action, props...}) ->
  onchange = (state, event) -> [action, {[event.target.name]: event.target.checked}]

  html.div {class: 'row mb-2'},
    for key, val of {
      sync: 'プロバイダーから取得'
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
            onchange
          }
          html.label {class: 'form-check-label', for: id}, text val
        ]

providerTh = ({provider}) ->
  html.th {key: "provider[#{provider.name}]"}, text entityLabel(provider)

groupProviderTd = ({group, provider}) ->
  html.td {key: "provider[#{provider.name}]"},
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
    when 'SYN'
      'light'
    else
      'light'
  html.tr {
    key: "group[#{group.name}]"
    class: "table-#{color}"
  }, [
    html.td {
      key: 'show'
      onclick: -> [SetGroupInList, {group..., show_detail: !group.show_detail}]
    }, BsIcon {name: if group.show_detail then 'chevron-down' else 'chevron-right'}
    html.td {key: 'action'},
      switch group.action
        when ''
          html.button {
            class: "btn btn-sm btn-outline-dark"
            onclick: -> [SyncGroup, group]
          }, text '取得'
        when 'ACT'
          html.div {class: 'spinner-border spinner-border-sm', role: 'status'},
            html.span {class: 'visually-hidden'}, text '実行中'
        when 'MOD', 'SYN'
          html.button {
            class: "btn btn-sm btn-#{color}"
            onclick: -> [DoActionUser, group]
          }, text ACTIONS.get(group.action)
        when 'ERR'
          html.div {}, text 'エラー'
        when 'SUC'
          html.div {}, text '成功'
        else
          html.div {}, text '？'
    html.td {key: 'name'},
      html.a {href: "/admin/groups/#{group.name}"}, text group.name
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
        unless group.action
          html.button {
            key: 'sync'
            class: 'btn btn-sm btn-light'
            onclick: -> [SyncGroup, group]
          }, text '同期'
        html.span {key: 'display_name'}, text "表示名: #{group.display_name || '(無し)'}"
        html.span {key: 'deleted_at', class: 'ms-2'}, text "削除日: #{group.deleted_at}" if group.deleted_at
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
      if group.providers_data?
        html.div {key: 'providers_data', class: 'small text-secondary'},
          for [provider, data] from group.providers_data
            html.div {key: provider}, text "#{provider}: #{JSON.stringify(data)}"
    ]

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
    mode: 'file'
    groups
    filename
  }

SetGroupInList = (state, group) ->
  {
    state...
    groups: updateGroupList(state.groups, group)
  }

SetGroupInListNextIfDoAll = (state, group) ->
  groups = updateGroupList(state.groups, group)
  [
    {
      state...
      groups
    }
    if group.action == 'ERR'
      runStopAllAction
    else if state.mode == 'do_all'
      [runDoNextAction, {list: groups, action: DoActionGroup}]
  ]

DoActionGroup = (state, group) ->
  switch group.action
    when 'MOD'
      [ModGroup, group]
    when 'SYN'
      [SyncGroup, group]
    else
      console.warn 'not implemented action: %s', group.action
      state

createActionGroup = (createEffecter, props = {}) ->
  (state, group) ->
    action = (_, data) ->
      if data?
        [SetGroupInListNextIfDoAll, {group..., data..., action: 'SUC', error: null}]
      else
        [SetGroupInListNextIfDoAll, {group..., action: 'ERR', error: '存在しません。', show_detail: true}]
    fallback = (_, error) ->
      [SetGroupInListNextIfDoAll, {group..., action: 'ERR', error, show_detail: true}]
    run = createEffecter({action, fallback})
    [
      {
        state...
        mode: if state.mode == 'file' then 'result' else state.mode
        groups: updateGroupList(state.groups, {group..., action: 'ACT'})
      }
      [run, {props..., group..., id: group.name}]
    ]

ModGroup = createActionGroup(createRunUpdateGroup)

SyncGroup = createActionGroup(createRunShowGroup, {sync: true})

PopState = (state, params) ->
  data = {
    pagination: {state.pagination..., pickType(params, PAGINATION_PARAM_TYPES)...}
    search: {state.search..., pickType(params, SEARCH_PARAM_TYPES)...}
    option: {state.option..., pickType(params, INDEX_GROUPS_OPTION_PARAM_TYPES)...}
    order: {state.order..., pickType(params, ORDER_PARAM_TYPES)...}
  }
  [ReloadIndexGroups, data]

# Effecters

runIndexProviders = createRunIndexProviders()

runIndexGroups = createRunIndexWithPageGroups({action: SetIndexGroups})

runPushHistory = (dispatch, params) ->
  query = "?#{objToUrlencoded(params)}"
  if (query != location.search)
    history.pushState(params, '', "#{location.pathname}#{query}")

# Subscribers

onPopstateSubscriber = (dispatch, action) ->
  listener = (event) -> dispatch(action, event.state)
  window.addEventListener 'popstate', listener
  -> window.removeEventListener 'popstate', listener

# create Subscriver
onPopstate = (action)->
  [onPopstateSubscriber, action]

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
    filename: 'groups.csv'
  }

  init = [
    initState
    [runIndexProviders, {has_groups: true}]
    [runIndexGroups, indexOptionFromState(initState)]
  ]

  view = ({mode, groups, providers, pagination, search, option, order, filename}) ->
    html.div {}, [
      batchOperation {
        mode
        list: groups
        header: {
          includes: GROUP_HEADERS
          excludes: ['show_detail']
        }
        filename
        onupload: UploadGroups
        action: DoActionGroup
      }
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
        html.table {class: 'table'}, [
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

  subscriptions = ({mode}) ->
    [
      onPopstate(PopState) if ['loading', 'loaded'].includes(mode)
    ]

  app {init, view, node, subscriptions}

main()
