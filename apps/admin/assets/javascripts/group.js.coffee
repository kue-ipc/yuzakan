# グループ

import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import {pick, pickType, getBasenameFromUrl, getQueryParamsFromUrl, entityLabel} from '/assets/common/helper.js'
import {objToUrlencoded} from '/assets/common/convert.js'
import valueDisplay from '/assets/app/value_display.js'

import {runIndexProviders} from '/assets/api/providers.js'
import {SHOW_GROUP_PARAM_TYPES, runShowGroup} from '/assets/api/groups.js'

import groupBasicInfo from '/assets/admin/group_basic_info.js'

# Views

providerReg = ({mode, group, providers}) ->
  html.div {}, [
    html.h4 {}, text '登録状況'
    html.table {class: 'table'}, [
      html.thead {},
        html.tr {}, [
          html.th {}, text '名前'
          # html.th {}, text '値'
          (html.th({}, text entityLabel(provider)) for provider in providers)...
        ]
      html.tbody {},
        for {name, label, type} in [
          {name: 'name', label: 'グループ名', type: 'string'}
          {name: 'display_name', label: '表示名', type: 'string'}
          {name: 'primary', label: 'プライマリ', type: 'boolean'}
        ]
          html.tr {}, [
            html.td {}, text label
            # html.td {}, valueDisplay {value: group[name], type}
            (for provider in providers
              groupdata = group.providers_data?.get(provider.name)
              html.td {},
                valueDisplay {
                  value: groupdata?[name]
                  type
                  color: if group[name]
                    if group[name] == groupdata?[name]
                      'success'
                    else
                      'danger'
                  else
                    'body'
                }
            )...
          ]
    ]
  ]

operationMenu = ({option}) ->
  html.div {}, [
    html.h4 {}, text '操作メニュー'
    html.p {}, text '準備中...'
  ]

ReloadShowGroup = (state, data) ->
  console.debug 'reload show group'
  newState = {state..., data...}
  params = pick({
    newState.option...
  }, Object.keys(SHOW_GROUP_PARAM_TYPES))
  [
    newState,
    [runPushHistory, params]
    [runShowGroup, {id: state.id, params...}]
  ]

ChangeOption = (state, option) ->
  [ReloadShowGroup, {option: {state.option..., option...}}]

# Effectors

runPushHistory = (dispatch, params) ->
  query = "?#{objToUrlencoded(params)}"
  if (query != location.search)
    history.pushState(params, '', "#{location.pathname}#{query}")

# main

main = ->
  id = getBasenameFromUrl(location)
  id = undefined if id == '*'
  mode = if id? then 'show' else 'new'

  queryParams = pickType(getQueryParamsFromUrl(location), SHOW_GROUP_PARAM_TYPES)

  init = [
    {mode, id, group: null, providers: [], option: queryParams}
    [runIndexProviders, {has_groups: true}]
    [runShowGroup, {id, queryParams...}]
  ]

  view = ({mode, id, group, providers, option}) ->
    if mode == 'none'
      return html.div {},
        html.strong {}, text 'グループが見つかりませんでした。'

    if mode == 'new'
      return html.div {},
        html.strong {}, text 'グループの新規作成はできません。'

    unless group? && providers?
      return html.div {}, text '読み込み中...'

    html.div {}, [
      groupBasicInfo {mode, group}
      operationMenu {option}
      providerReg {mode, group, providers}
    ]

  node = document.getElementById('group')

  app {init, view, node}

main()
