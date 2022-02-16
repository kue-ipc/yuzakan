# import loginForm from './login_form.js?v=0.6.0'

# loginForm {
#   loginNode: document.getElementById('login')
#   successLink: '/'
# }


import WebData from './web_data.js?v=0.6.0'
import BsIcon from './bs_icon.js?v=0.6.0'
import {app, h, text} from './hyperapp.js?v=0.6.0'
import csrf from './csrf.js?v=0.6.0'

webData = new WebData {
  title: 'ログイン'
  method: 'POST'
  url: '/api/session'
  statusActions: new Map [
    ['success', {redirectTo: '/'}]
  ]
}

login = (dispatch) ->
  await webData.submitPromise({data: {
    csrf()...
  }})

init = {
  username: null
  password: null
}

view = (state) ->
  h 'div', {id: 'login', class: 'login mx-auto p-3 border rounded'}, [
    h 'h3', {class: 'login-title text-center mb-2'}, text 'ログイン'
    h 'div', {class: 'mb-3'},
      h 'input', {
        class: 'form-control', type: 'text', required: true, placeholder: 'ユーザー名'
        onkeyup: (state, event) -> {state..., username: event.target.value}
      }
    h 'div', {class: 'mb-3'},
      h 'input', {
        class: 'form-control', type: 'password', required: true, placeholder: 'パスワード'
        onkeyup: (state, event) -> {state..., password: event.target.value}
      }
    h 'div', {class: 'd-grid gap-auto'},
      h 'button', {
        class: 'login-submit btn btn-primary d-flex align-items-center justify-content-center'
        disabled: !(state.username && state.password)
      }, [
        BsIcon {name: 'box-arrow-in-left', class: 'flex-shrink-0 me-1'}
        text 'ログイン'
      ]
  ]

node = document.getElementById('login')

app {init, view, node}
