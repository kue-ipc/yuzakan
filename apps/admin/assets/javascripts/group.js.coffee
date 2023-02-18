# グループ

import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import {pick, pickType, getBasenameFromUrl, getQueryParamsFromUrl} from '/assets/utils.js'
import {objToUrlencoded} from '/assets/form_helper.js'
import {dlClasses, dtClasses, ddClasses} from '/assets/dl_horizontal.js'
import BsIcon from '/assets/bs_icon.js'
import valueDisplay from '/assets/value_display.js'

import {createRunIndexProviders} from '/assets/api/providers.js'
import {createRunShowGroup} from '/assets/api/groups.js'
import {SHOW_GROUP_PARAM_TYPES} from '/assets/api/groups.js'

# Views

basicInfo = ({mode, group}) ->
  html.h4 {}, text '基本情報'
  html.dl {class: dlClasses}, [
    html.dt {class: dtClasses},
      text 'グループ名'
    html.dd {class: ddClasses},
      text group.name
    html.dt {class: dtClasses},
      text '表示名'
    html.dd {class: ddClasses},
      text group.display_name ? ''
    html.dt {class: dtClasses},
      text 'プライマリ'
    html.dd {class: ddClasses},
      if group.primary
        html.span {class: 'text-success'},
          BsIcon({name: 'check-square'})
      else
        html.span {class: 'text-muted'},
          BsIcon({name: 'square'})
    html.dt {class: dtClasses},
      text '状態'
    html.dd {class: ddClasses},
      if group.deleted
        html.span {class: 'text-failure'},
          text "削除済み(#{group.deleted_at})"
      else if group.prohibited
        html.span {class: 'text-muted'},
          text '使用禁止'
      else
        html.span {class: 'text-success'},
          text '正常'
    html.dt {class: dtClasses},
      text '備考'
    html.dd {class: ddClasses},
      text group.note ? ''
  ]

providerReg = ({mode, group, providers}) ->
  group_providers = new Map(group.providers)

  html.h4 {}, text '登録状況'

  html.table {class: 'table'}, [
    html.thead {},
      html.tr {}, [
        html.th {}, text '名前'
        # html.th {}, text '値'
        (html.th({}, text provider.label) for provider in providers)...
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
            groupdata = group_providers.get(provider.name)
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

operationMenu = ({option}) ->
  html.div {}, [
    if option?.sync
      html.button {
        class: 'btn btn-primary'
        disbled: true
      }, text 'プロバイダーと同期'
    else
      html.button {
        class: 'btn btn-primary'
        onclick: -> [ChangeOption, {sync: true}]
      }, text 'プロバイダーと同期'
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

runIndexProviders = createRunIndexProviders()

runShowGroup = createRunShowGroup()

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
      basicInfo {mode, group}
      operationMenu {option}
      providerReg {mode, group, providers}
    ]

  node = document.getElementById('group')

  app {init, view, node}

main()
