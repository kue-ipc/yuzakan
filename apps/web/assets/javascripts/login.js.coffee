import './modern_browser.js'

import {alertMessage} from './alert.js'

loginSet = (form) ->
  if form.tagName != 'FORM'
    loginSet(elm) for elm in form.getElementsByTagName('form')
    return

  form.onsubmit = (e) ->
    formData = new FormData(e.target)

    disableSubmit()
    for submit in submitButtonNodes
      submit.textContent = 'ログイン処理中...'
    input.disabled = true for input in inputTextNodes
    alertMessage {
      info: 'ログイン処理を実行中です。しばらくお待ち下さい。'
    }

    loginAction = fetch form.action,
      method: 'POST'
      mode: 'same-origin'
      credentials: 'same-origin'
      headers:
        'Accept': 'application/json'
      body: formData

    loginAction
      .then (response) ->
        data = await response.json()
        if data.result == 'success'
          alertMessage {
            info: '画面を切り替えています。しばらくお待ち下さい。'
            data.messages...
          }
          location.reload()
          return
        else
          alertMessage data.messages

          for input in inputTextNodes
            input.value = ''
            input.disabled = false
          for submit in submitButtonNodes
            submit.textContent = 'ログイン'

      .catch (error) ->
        console.log error
        alertClear()
        alertMessage
          error: "サーバー接続時にエラーが発生しました。: #{error}"
        for input in inputTextNodes
          input.value = ''
          input.disabled = false
        for submit in submitButtonNodes
          submit.textContent = 'ログイン'

    false


  submitButtonSelector = 'button[type="submit"]'
  submitButtonNodes = form.querySelectorAll(submitButtonSelector)

  disableSubmit = ->
    submit.disabled = true for submit in submitButtonNodes

  enableSubmit = ->
    submit.disabled = false for submit in submitButtonNodes

  disableSubmit()

  inputTextSelector = 'input[type="text"], input[type="password"]'
  inputTextNodes = form.querySelectorAll(inputTextSelector)

  checkValid = ->
    if Array::every.call inputTextNodes, (input) -> input.checkValidity()
      enableSubmit()
    else
      disableSubmit()

  for input in inputTextNodes
    input.addEventListener 'keyup', checkValid

loginNodes = document.getElementsByClassName('login-form')
loginSet(node) for node in loginNodes
