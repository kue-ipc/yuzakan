import './modern_browser.js'

loginSet = (node) ->
  submitButtonNodes = node.getElementsByClassName('login-submit')
  submit.disabled = true for submit in submitButtonNodes
  inputNodes = node.getElementsByTagName('INPUT')
  checkValid = ->
    if Array::every.call inputNodes, (input) -> input.checkValidity()
      submit.disabled = false for submit in submitButtonNodes
    else
      submit.disabled = true for submit in submitButtonNodes
  for input in inputNodes
    input.addEventListener 'keyup', (_e) -> checkValid()

loginNodes = document.getElementsByClassName('login')
loginSet(node) for node in loginNodes
