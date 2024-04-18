clickOnlyOnceSet = (form) ->
  return if form.tagName != 'FORM'

  submitButton = form.getElementsByClassName('submit')[0]

  form.addEventListener 'submit', (e) ->
    submitButton.disabled = true

for form in document.getElementsByClassName('click-only-once')
  clickOnlyOnceSet(form)
