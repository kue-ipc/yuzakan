# グループ

import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'
import {fetchJsonGet} from '../fetch_json.js'
import {fieldName, fieldId} from '../form_helper.js'
import csrf from '../csrf.js'
import {DL_CLASSES, DT_CLASSES, DD_CLASSES} from '../dl_horizontal.js'

parentNames = ['group']

groupAction = (state, {name, group}) ->
  history.pushState(null, null, "/admin/groups/#{name}") if name? && name != state.name

  {
    state...
    name: name ? state.name
    group: {state.group..., group...}
  }

showGroupRunner = (dispatch, {name}) ->
  return unless name?

  response = await fetchJsonGet({url: "/api/groups/#{name}"})
  if response.ok
    dispatch(groupAction, {group: response.data})
  else
    console.error respons

initAllProvidersAction = (state, {providers}) ->
  # providers group only
  {state..., providers: (provider for provider in providers when provider.group)}

indexAllProvidersRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/providers'})
  if response.ok
    dispatch(initAllProvidersAction, {providers: response.data})
  else
    console.error response

name = location.pathname.split('/').at(-1)
name = undefined if name == '*'
mode = if name? then 'show' else 'new'

initGroup = {
  name: ''
  groupdata: {}
  provider_groupdatas: []
}

init = [
  {mode, name, group: initGroup, providers: [], attrs: []}
  [indexAllProvidersRunner]
  [showGroupRunner, {name}]
]

view = ({mode, name, group, providers}) ->
  provider_groupdatas =
    for provider in providers
      (group.provider_groupdatas.find (data) -> data.provider.name == provider.name)?.groupdata

  html.div {}, [
    html.h4 {}, text '基本情報'
    html.dl {class: DL_CLASSES}, [
      html.dt {class: DT_CLASSES},
        text 'グループ名'
      html.dd {class: DD_CLASSES},
        text group.name
      html.dt {class: DT_CLASSES},
        text '表示名'
      html.dd {class: DD_CLASSES},
        text group.display_name ? ''
    ]

    html.h4 {}, text '登録状況'

    html.table {class: 'table'}, [
      html.thead {},
        html.tr {}, [
          html.th {}, text '名前'
          html.th {}, text '値'
          (html.th({}, text provider.label) for provider in providers)...
        ]
      html.tbody {},
        for {name, label} in [
          {name: 'name', label: 'グループ名'}
          {name: 'display_name', label: '表示名'}
        ]
          html.tr {}, [
            html.td {}, text label
            html.td {}, text group[name] ? ''
            (
              for groupdata in provider_groupdatas
                html.td {},
                  if not groupdata?[name]
                    html.span {class: 'text-muted'}, text 'N/A'
                  else if group[name] == groupdata[name]
                    html.span {class: 'text-success'}, text groupdata?[name]
                  else
                    html.span {class: 'text-danger'}, text groupdata?[name]
            )...
          ]
    ]
  ]

node = document.getElementById('admin_group')

app {init, view, node}
