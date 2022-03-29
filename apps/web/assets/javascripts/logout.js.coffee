import {app, text} from './hyperapp.js?v=0.6.0'
import * as html from './hyperapp-html.js?v=0.6.0'
import WebData from './web_data.js?v=0.6.0'
import BsIcon from './bs_icon.js?v=0.6.0'
import csrf from './csrf.js?v=0.6.0'

webData = new WebData {
  id: 'logout'
  title: 'ログアウト'
  method: 'DELETE'
  url: '/api/session'
  codeActions: new Map [
    [200, {status: 'success', message: 'ログアウトしました。', redirectTo: '/'}]
    [410, {status: 'error', message: '既にログアウトしています。', reload: true}]
  ]
}

logout = (dispatch) ->
  await webData.submitPromise({data: csrf()})
  
view = (state) ->
  html.button {
    class: state.buttonClassList
    onclick: (state, event) ->
      [state, [logout]]
  }, [
    BsIcon {name: 'box-arrow-right', class: 'flex-shrink-0 me-1'}
    html.span {class: 'd-none d-md-inline'}, text 'ログアウト'
  ]

defaultButtonClassList = 'btn btn-sm btn-outline-light d-flex align-items-center'.split(' ').filter((_) -> _)

for el in document.getElementsByClassName('logout-button')
  init = {
    buttonClassList: [name for name in el.classList when name != 'logout-button'].concat(defaultButtonClassList)
  }
  app {init, view, node: el}
