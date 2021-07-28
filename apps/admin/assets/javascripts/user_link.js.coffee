import {h, text, app} from '../hyperapp.js'

initState = {
  username: ''
}

view = (state) ->
  link_class = ['btn', 'btn-primary']
  if !state.username? || state.username.length == 0
    link_class.push('disabled')
  h 'div', class: ['form-row'], [
    h 'div', class: ['col'],
      h 'input',
        class: ['form-control']
        oninput: (_, e) =>
          {username: e.target.value}
    h 'div', class: ['col'],
      h 'a',
        class: link_class
        href: "/admin/users/#{state.username}"
        text 'ユーザーを表示'
  ]


mainNode = document.getElementById('user_link')

app
  init: initState
  view: view
  node: mainNode
