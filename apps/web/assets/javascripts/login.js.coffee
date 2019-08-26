import './modern_browser.js'

import {alertMessage} from './alert.js'
import bsn from './bootstrap-native.js'

clearChildren = (node) ->
  node.removeChild(node.firstChild) while node.firstChild

modalMessag = (modal, titleNode, bodyNode, closeNodes,
    {status, title, messages, closable = false}) ->
  icon = document.createElement('i')
  icon.className =
    switch status
      when 'running' then 'fas fa-spinner fa-spin text-primary'
      when 'success' then 'fas fa-check text-success'
      when 'failure' then 'fas fa-times text-danger'
      when 'error' then 'fas fa-exclamation text-danger'

  clearChildren(titleNode)
  titleNode.appendChild(icon)
  titleNode.appendChild(document.createTextNode(' ' + title))

  messages = [messages] unless messages instanceof Array
  clearChildren(bodyNode)
  for message in messages
    messageNode = document.createElement('div')
    messageNode.textContent = message
    bodyNode.appendChild(messageNode)

  if closable
    closeNode.hidden = false for closeNode in closeNodes
    modal.backdrop = true
    modal.keyboard = true
  else
    closeNode.hidden = true for closeNode in closeNodes
    modal.backdrop = 'static'
    modal.keyboard = false

loginSet = (formNode, modalNode) ->
  modal = new bsn.Modal(modalNode, {
    backdrop: 'static'
    keyboard: false
    show: false
  })

  titleNode = modalNode.getElementsByClassName('modal-title')[0]
  bodyNode = modalNode.getElementsByClassName('modal-body')[0]
  closeNodes = [
    modalNode.getElementsByClassName('close')[0]
    modalNode.getElementsByClassName('modal-footer')[0]
  ]

  formNode.onsubmit = (e) ->
    formData = new FormData(e.target)

    disableSubmit()
    input.disabled = true for input in inputTextNodes

    modalMessag modal, titleNode, bodyNode, closeNodes, {
      status: 'running'
      title: 'ログイン処理中'
      messages: 'ログインを実施しています。しばらくお待ち下さい。'
    }
    modal.show()

    loginAction = fetch formNode.action,
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
          modalMessag modal, titleNode, bodyNode, closeNodes, {
            status: 'success'
            title: 'ログイン成功'
            messages: '画面を切り替えています。しばらくお待ち下さい。'
          }
          location.reload()
          return
        else
          modalMessag modal, titleNode, bodyNode, closeNodes, {
            status: 'failure'
            title: 'ログイン失敗'
            messages: data.messages.errors
            closable: true
          }
          for input in inputTextNodes
            input.value = ''
            input.disabled = false
      .catch (error) ->
        console.log error
        modalMessag modal, titleNode, bodyNode, closeNodes, {
          status: 'error'
          title: '接続エラー'
          messages: [
            'サーバー接続時にエラーが発生しました。しばらく待ってから、再度ログインしてください。'
            "エラー内容: #{error}"
          ]
          closable: true
        }
        for input in inputTextNodes
          input.disabled = false

    false


  submitButtonSelector = 'button[type="submit"]'
  submitButtonNodes = formNode.querySelectorAll(submitButtonSelector)

  disableSubmit = ->
    submit.disabled = true for submit in submitButtonNodes

  enableSubmit = ->
    submit.disabled = false for submit in submitButtonNodes

  disableSubmit()

  inputTextSelector = 'input[type="text"], input[type="password"]'
  inputTextNodes = formNode.querySelectorAll(inputTextSelector)

  checkValid = ->
    if Array::every.call inputTextNodes, (input) -> input.checkValidity()
      enableSubmit()
    else
      disableSubmit()

  for input in inputTextNodes
    input.addEventListener 'keyup', checkValid

loginNode = document.getElementById('login')
loginFormNode = loginNode.getElementsByTagName('form')[0]
loginModalNode = document.getElementById('login-modal')
loginSet(loginFormNode, loginModalNode)
