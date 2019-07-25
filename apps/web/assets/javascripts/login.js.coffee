import './modern_browser.js'

addAlert = (message) ->
  for alerts in document.getElementsByClassName('alerts')
    div = document.createElement('div')
    div.className = 'alert alert-danger alert-dismissible fade show'
    div.setAttribute('role', 'alert')

    text = document.createTextNode(message)

    button = document.createElement('button')
    button.className = 'close'
    button.setAttribute('type', 'button')
    button.setAttribute('data-dismiss', 'alert')
    button.setAttribute('aria-label', '閉じる')

    span = document.createElement('span')
    span.setAttribute('aria-hidden', 'true')

    i = document.createElement('i')
    i.className = 'fas fa-times'

    span.appendChild(i)
    button.appendChild(span)
    div.appendChild(button)
    div.appendChild(text)
    alerts.appendChild(div)

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
          location.reload()
          return
        else
          addAlert(data.message)
          for input in inputTextNodes
            input.value = ''
            input.disabled = false
          for submit in submitButtonNodes
            submit.textContent = 'ログイン'
      .catch (error) ->
        console.log error
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
