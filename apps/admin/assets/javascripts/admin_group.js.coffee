# グループ

import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'
import {fetchJsonGet} from '../api/fetch_json.js'
import {fieldName, fieldId} from '../form_helper.js'
import csrf from '../csrf.js'
import {dlClasses, dtClasses, ddClasses} from '../dl_horizontal.js'
import BsIcon from '../bs_icon.js'

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
    console.error response

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
  group_providers = new Map(group.providers)

  html.div {}, [
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
          {name: 'groupname', label: 'グループ名'}
          {name: 'display_name', label: '表示名'}
          {name: 'prymary', label: 'プライマリ'}
        ]
          html.tr {}, [
            html.td {}, text label
            html.td {}, text group[name] ? ''
            (
              for provider in providers
                groupdata = group_providers.get(provider.name)
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
