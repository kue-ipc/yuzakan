
submitBeforeAgreementSet = (form) ->
  return if form.tagName != 'FORM'

  agreementInput = form.getElementsByClassName('agreement')[0]
  submitButton = form.getElementsByClassName('submit')[0]

  if agreementInput? && submitButton?
    agreementInput.addEventListener 'change', (e) ->
      if e.target.checked
        submitButton.disabled = false
      else
        submitButton.disabled = true

for form in document.getElementsByClassName('submit-before-agreement')
  submitBeforeAgreementSet(form)
