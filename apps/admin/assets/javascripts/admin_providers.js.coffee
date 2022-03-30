import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'
import {fetchJsonGet} from '../fetch_json.js'

attrTr = ({provider}) ->
  html.tr {}, [
    html.td {},
      html.a {href: "/admin/providers/#{provider.name}"}, text provider.name
    html.td {}, text provider.label
    html.td {}, text provider.adapter_name
    html.td {}, if provider.check?
      if provider.check
        html.span {class: 'text-success'}, text 'OK'
      else
        html.span {class: 'text-danger'}, text 'NG'
    else
      html.span {class: 'text-secondary'}, text '確認中'
  ]

providerAction = (state, {name, provider}) ->
  name ?= provider.name
  providers = for current in state.providers
    if current.name == name
      {current..., provider...}
    else
      current
  {state..., providers}

initAllProvidersAction = (state, {providers}) ->
  [
    {state..., providers}
    ([checkProviderRunner, {provider}] for provider in providers)...
  ]

checkProviderRunner = (dispatch, {provider}) ->
  response = await fetchJsonGet({url: "/api/providers/#{provider.name}/check"})
  if response.ok
    dispatch(providerAction, {name: provider.name, provider: response.data})
  else
    console.log respons

indexAllProvidersRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/providers'})
  if response.ok
    dispatch(initAllProvidersAction, {providers: response.data})
  else
    console.error response

init = [
  {providers: []}
  [indexAllProvidersRunner]
]

view = ({providers}) ->
  html.table {class: 'table'}, [
    html.thead {},
      html.tr {}, [
        html.th {}, text '名前'
        html.th {}, text '表示名'
        html.th {}, text 'アダプター'
        html.th {}, text '状態'
      ]
    html.tbody {}, (attrTr({provider}) for provider in providers)
  ]

node = document.getElementById('admin_providers')

app {init, view, node}