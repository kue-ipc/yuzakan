import {app, text} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'
import WebData from '/assets/app/web_data.js'
import BsIcon from '/assets/app/bs_icon.js'
import csrf from '/assets/csrf.js'

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
