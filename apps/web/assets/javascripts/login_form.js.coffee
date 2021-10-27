import './modern_browser.js'

import WebPostJson from './web_post_json.js'

clearChildren = (node) ->
  node.removeChild(node.firstChild) while node.firstChild

loginSet = (formNode, {successLink = '/'}) ->
  webPost = new WebPostJson
    form: formNode
    title: 'ログイン'
    messages: {
      running: 'ログインを実施しています。しばらくお待ち下さい。'
      success: '画面を切り替えています。しばらくお待ち下さい。'
    }
    successLink: successLink
    reloadTime: 0

  formNode.addEventListener 'submit', (e) ->
    e.preventDefault()
    (->
      {result, messages} = await webPost.submitPromise()
      if result == 'success'
        # do nothing
      else
        for input in inputTextNodes
          input.value = ''
          disableSubmit()
    )()

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
    input.disabled = false
    input.addEventListener 'keyup', checkValid

export default loginForm = ({loginNode, successLink}) ->
  loginFormNode = loginNode.getElementsByTagName('form')[0]
  loginSet(loginFormNode, {successLink})

