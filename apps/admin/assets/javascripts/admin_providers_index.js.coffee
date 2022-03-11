import {h, text, app} from '../hyperapp.js?v=6.0.0'
import {div, table, thead, tbody, tr, th, td, a} from '../hyperapp-html.js?v=0.6.0'
import {fetchJsonGet} from '../fetch_json.js?v=0.6.0'

attrTr = ({provider}) ->
  tr {}, [
    td {}, text provider.name
    td {}, text provider.label
    td {}, text provider.adapter_name
    td {}, text provider.check ? '確認中'
  ]

initAllProvidersAction = (state, {providers}) ->
  {state..., providers}

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
    tbody {}, providers.map (provider) -> attrTr({provider})
  ]

node = document.getElementById('admin_providers_index')

app {init, view, node}
