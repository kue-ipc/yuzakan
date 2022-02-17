import WebData from './web_data.js?v=0.6.0'
import BsIcon from './bs_icon.js?v=0.6.0'
import {app, text} from './hyperapp.js?v=0.6.0'
import {button, span} from './hyperapp-html.js?v=0.6.0'
import csrf from './csrf.js?v=0.6.0'


webData = new WebData {
  id: 'logout'
  title: 'ログアウト'
  method: 'DELETE'
  url: '/api/session'
  statusActions: new Map [
    ['success', {redirectTo: '/'}]
  ]
}

logout = (dispatch) ->
  await webData.submitPromise({data: csrf()})
  
view = (state) ->
  button {
    class: state.buttonClassList
    onclick: (state, event) ->
      [state, [logout]]
  }, [
    BsIcon {name: 'box-arrow-right', class: 'flex-shrink-0 me-1'}
    span {class: 'd-none d-md-inline'}, text 'ログアウト'
  ]

defaultButtonClassList = 'btn btn-sm btn-outline-light d-flex align-items-center'.split(' ').filter((_) -> _)

for el in document.getElementsByClassName('logout-button')
  init = {
    buttonClassList: [name for name in el.classList when name != 'logout-button'].concat(defaultButtonClassList)
  }
  app {init, view, node: el}
