# グループ

import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import {fetchJsonGet} from '/assets/api/fetch_json.js'
import {fieldName, fieldId} from '/assets/form_helper.js'
import csrf from '/assets/csrf.js'

import {dlClasses, dtClasses, ddClasses} from '/assets/dl_horizontal.js'
import BsIcon from '/assets/bs_icon.js'
import valueDisplay from '/assets/value_display.js'

import {runGetProviders} from '/assets/api/providers.js'

# import operationMenu from './group_operation_menu.js'

parentNames = ['group']

SetMode = (state, mode) -> {state..., mode}

SetGroup = (state, {name, group}) ->
  history.pushState(null, null, "/admin/groups/#{name}") if name? && name != state.name

  {
    state...
    name: name ? state.name
    group: {state.group..., group...}
  }

runGetGroup = (dispatch, {name}) ->
  return unless name?

  response = await fetchJsonGet({url: "/api/groups/#{name}"})
  if response.ok
    dispatch(SetGroup, {group: response.data})
  else
    console.error response
    dispatch(SetMode, 'none')

name = location.pathname.split('/').at(-1)
name = undefined if name == '*'
mode = if name? then 'show' else 'new'

init = [
  {mode, name, group: null, providers: null}
  [runGetProviders]
  [runGetGroup, {name}]
]

basicInfo = ({mode, group}) ->
  html.h4 {}, text '基本情報'
  html.dl {class: dlClasses}, [
    html.dt {class: dtClasses},
      text 'グループ名'
    html.dd {class: ddClasses},
      text group.groupname
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
      else if group.obsoleted
        html.span {class: 'text-muted'},
          text '廃止'
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
        (html.th({}, text provider.label) for provider in providers when provider.group)...
      ]
    html.tbody {},
      for {name, label, type} in [
        {name: 'groupname', label: 'グループ名', type: 'string'}
        {name: 'display_name', label: '表示名', type: 'string'}
        {name: 'primary', label: 'プライマリ', type: 'boolean'}
      ]
        html.tr {}, [
          html.td {}, text label
          # html.td {}, valueDisplay {value: group[name], type}
          (
            # only provider that has group
            for provider in providers when provider.group
              groupdata = group_providers.get(provider.name)
              html.td {},
                valueDisplay {
                  value: groupdata?[name]
                  type
                  color: 
                    if group[name]
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

view = ({mode, name, group, providers}) ->
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
    # operationMenu {mode, group}
    providerReg {mode, group, providers}
  ]

node = document.getElementById('group')

app {init, view, node}
