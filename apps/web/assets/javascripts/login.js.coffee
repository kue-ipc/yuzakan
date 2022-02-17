import WebData from './web_data.js?v=0.6.0'
import BsIcon from './bs_icon.js?v=0.6.0'
import {app, h, text, focus} from './hyperapp.js?v=0.6.0'
import csrf from './csrf.js?v=0.6.0'

webData = new WebData {
  title: 'ログイン'
  method: 'POST'
  url: '/api/session'
  statusActions: new Map [
    ['success', {redirectTo: '/'}]
  ]
}

submittable = ({username, password, disabled}) -> not disabled and username and password

runLogin = (dispatch, payload) ->
  await webData.submitPromise {data: {
    csrf()...
    session: payload
  }}
  dispatch (state) -> {
    state...
    disabled: false
    username: null
    password: null
  }

login = ({username, password}) -> [runLogin, {username, password}]


enterToSubmitOrNextInput = (state, event) ->
  if event.keyCode == 13
    if submittable(state)
      [{state..., disabled: true}, login(state)]
    else if event.target.id == 'session-username'
      [state, focus('session-password')]
    else
      [state, focus('session-username')]
  else
    state

init = {
  disabled: false
  username: null
  password: null
}

view = ({username, password, disabled}) ->
  h 'div', {id: 'login', class: 'login mx-auto p-3 border rounded'}, [
    h 'h3', {class: 'login-title text-center mb-2'}, text 'ログイン'
    h 'div', {class: 'mb-3'},
      h 'input', {
        id: 'session-username'
        class: 'form-control', type: 'text', required: true, placeholder: 'ユーザー名'
        disabled
        value: username
        oninput: (state, event) -> {state..., username: event.target.value}
        onkeypress: enterToSubmitOrNextInput
      }
    h 'div', {class: 'mb-3'},
      h 'input', {
        id: 'session-password
        '
        class: 'form-control', type: 'password', required: true, placeholder: 'パスワード'
        disabled
        value: password
        oninput: (state, event) -> {state..., password: event.target.value}
        onkeypress: enterToSubmitOrNextInput
      }
    h 'div', {class: 'd-grid gap-auto'},
      h 'button', {
        class: 'login-submit btn btn-primary d-flex align-items-center justify-content-center'
        disabled: not submittable({username, password, disabled})
        onclick: (state, event) -> [{state..., disabled: true}, login(state)]
      }, [
        BsIcon {name: 'box-arrow-in-left', class: 'flex-shrink-0 me-1'}
        text 'ログイン'
      ]
  ]

node = document.getElementById('login')

app {init, view, node}
