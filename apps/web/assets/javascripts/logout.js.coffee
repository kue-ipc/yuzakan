import WebData from './web_data.js?v=0.6.0'


webData = new WabData {
  title: 'ログアウト'
  url: '/api/session'
  method: 'DELETE'
  statuses: new Map [
    ['success', {ridirectTo: '/', reloadTime: 10}]
  ]
}

for el in document.getElementsByClassName('logout-button')
  el.addEventListener 'click', (e) ->
    e.preventDefault()
    (->
      data = await webData.submitPromise {
        method: 'DELETE'
        url: '/api/session'
      }

      if result == 'success'
        # do nothing
      else
        for input in inputTextNodes
          input.value = ''
          disableSubmit()
    )()


import loginForm from './login_form.js?v=0.6.0'

loginForm {
  loginNode: document.getElementById('login')
  successLink: '/'
}
