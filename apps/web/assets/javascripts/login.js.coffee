import {app, text} from 'hyperapp'
import * as html from '@hyperapp/html'
import {focus} from '@hyperapp/dom'
import {delay} from '@hyperapp/time'
import WebData from '~/app/web_data.js'
import bsIcon from '~/app/bs_icon.js'
import csrf from '~/csrf.js'

webData = new WebData {
  id: 'login'
  title: 'ログイン'
  method: 'POST'
  url: '/api/session'
  codeActions: new Map [
    [201, {status: 'success', message: 'ログインに成功しました。', redirectTo: '/'}]
    [400, {status: 'failure', message: 'ログインに失敗しました。'}]
    [403, {status: 'error', message: 'アクセスする権限がありません。'}]
    [422, {status: 'failure', message: 'ログインに失敗しました。'}]
  ]
}

submittable = ({username, password, disabled}) -> not disabled and username and password

runLogin = (dispatch, payload) ->
  await webData.submitPromise {data: {
    csrf()...
    payload...
  }}
  dispatch (state) -> [
    {
      state...
      disabled: false
      password: null
    }
    focus('session-username')
  ]

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

init = [
  {
    disabled: false
    username: null
    password: null
  }
  delay 10, (state) -> [state, focus('session-username')]
]

view = ({username, password, disabled}) ->
  html.div {id: 'login', class: 'login mx-auto p-3 border rounded'}, [
    html.h3 {class: 'login-title text-center mb-2'}, text 'ログイン'
    html.div {class: 'mb-3'},
      html.input {
        id: 'session-username'
        class: 'form-control', type: 'text', required: true, placeholder: 'ユーザー名'
        disabled
        value: username
        oninput: (state, event) -> {state..., username: event.target.value}
        onkeypress: enterToSubmitOrNextInput
      }
    html.div {class: 'mb-3'},
      html.input {
        id: 'session-password
        '
        class: 'form-control', type: 'password', required: true, placeholder: 'パスワード'
        disabled
        value: password
        oninput: (state, event) -> {state..., password: event.target.value}
        onkeypress: enterToSubmitOrNextInput
      }
    html.div {class: 'd-grid gap-auto'},
      html.button {
        class: 'login-submit btn btn-primary d-flex align-items-center justify-content-center'
        disabled: not submittable({username, password, disabled})
        onclick: (state, event) -> [{state..., disabled: true}, login(state)]
      }, [
        bsIcon {name: 'box-arrow-in-left', class: 'flex-shrink-0 me-1'}
        text 'ログイン'
      ]
  ]

node = document.getElementById('login')

app {init, view, node}
