# path: /admin/providers
# node: providers

import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'
import {fetchJsonGet} from '/assets/api/fetch_json.js'

providerTr = ({provider}) ->
  html.tr {}, [
    html.td {},
      html.a {href: "/admin/providers/#{provider.name}"}, text provider.label
    html.td {}, text provider.name
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
    console.error response

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
        html.th {}, text '識別子'
        html.th {}, text 'アダプター'
        html.th {}, text '状態'
      ]
    html.tbody {}, (providerTr({provider}) for provider in providers)
  ]

node = document.getElementById('providers')

app {init, view, node}
