import {h, text, app} from '../hyperapp.js?v=6.0.0'
import {div, span, table, thead, tbody, tr, th, td, a} from '../hyperapp-html.js?v=0.6.0'
import {fetchJsonGet} from '../fetch_json.js?v=0.6.0'

attrTr = ({provider}) ->
  tr {}, [
    td {},
      a {href: "/admin/providers/#{provider.name}"}, text provider.name
    td {}, text provider.label
    td {}, text provider.adapter_name
    td {}, if provider.check?
      if provider.check
        span {class: 'text-success'}, text 'OK'
      else
        span {class: 'text-danger'}, text 'NG'
    else
      span {class: 'text-secondary'}, text '確認中'
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
  table {class: 'table'}, [
    thead {},
      tr {}, [
        th {}, text '名前'
        th {}, text '表示名'
        th {}, text 'アダプター'
        th {}, text '状態'
      ]
    tbody {}, (attrTr({provider}) for provider in providers)
  ]

node = document.getElementById('admin_providers_index')

app {init, view, node}
