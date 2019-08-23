import './modern_browser.js'

import {h, app} from './hyperapp.js'
import {preventDefault, targetValue} from './hyperapp-events.js'
import {div, i, label, input, button} from './hyperapp-html.js'
import zxcvbn from './zxcvbn.js'

import {alertMessage} from './alert.js'
import {listToField, listToKebab, camelize} from './string_utils.js'

changePasswordNode = document.getElementById('change-password')
changePasswordData = JSON.parse(changePasswordNode.getAttribute(
  'data-change-password'))

changePasswordForm = document.getElementById(changePasswordData.form)

paramErrorsNode = document.getElementById('param-errors')
paramErrors =
  if paramErrorsNode?
    JSON.parse(paramErrorsNode.innerText)
  else
    {}

SCORE_LABELS = [
  {tag: 'danger', label: '危険'}
  {tag: 'warning', label: '脆弱'}
  {tag: 'secondary', label: '弱い'}
  {tag: 'info', label: '強い'}
  {tag: 'success', label: '安全'}
]

includeCharsInString = (chars, str) ->
  Array::some.call chars, (char) ->
    str.includes(char)

countCharType = (str) ->
  count = 0
  types = [
    /[0-9]/
    /[a-z]/
    /[A-Z]/
    /[^0-9a-zA-Z]/
  ]
  for re in types
    count += 1 if re.test(str)
  count

calcStrength = (str, dict = []) ->
  result = zxcvbn(str, [dict..., changePasswordData.config.dict...])
  {
    score: result.score
    strength: result.guesses_log10 * 7
  }

StrengthIndicator = ({score, strength}) =>
  scoreLabel =
    if score == 0 && strength == 0
      {tag: 'danger', label: ''}
    else
      SCORE_LABELS[score]

  strength = 100 if strength >= 100

  div class: 'row mb-3', [
    div class: changePasswordData.cols.left
    div class: changePasswordData.cols.right,
      div class: 'progress', style: {height: '2em'},
        div
          class: "progress-bar bg-#{scoreLabel.tag}",
          style: {width: "#{strength}%"}
          role: 'progressbar'
          'aria-valuenow': strength
          'aria-valuemin': '0'
          'aria-valuemax': '100'
          scoreLabel.label
  ]

class PasswordInputGenerator
  constructor: ({@name, @label, error = null} ) ->
    @camelName = camelize(@name)
    @nameList = [changePasswordData.parents..., @name]
    @idName = listToKebab(@nameList...)
    @fieldName = listToField(@nameList...)

  init: () ->
    state =
      visible: false
      valid: false
      value: ''
      entered: false
    if error?
      Object.assign @state,
        wasValidated: true
        message: error
    state

  showPassword: (state, visible) => {
    state...
    [@camelName]: {
      state[@camelName]...
      visible
    }
  }

  resetValid: (state) => {
    state...
    [@camelName]: {
      state[@camelName]...
      valid: false
      wasValidated: false
    }
  }

  setValid: (state, message) => {
    state...
    [@camelName]: {
      state[@camelName]...
      valid: true
      wasValidated: state[@camelName].entered
      message
    }
  }

  setInvalid: (state, message) => {
    state...
    [@camelName]: {
      state[@camelName]...
      valid: false
      wasValidated: state[@camelName].entered
      message
    }
  }

  setValue: (state, value) =>
    checkPassword({
      state...
      [@camelName]: {
        state[@camelName]...
        value: value
        entered: true
      }
    })

  view: ({visible, valid, wasValidated, message, inputPassword, disabled}) =>
    validState =
      if wasValidated
        if valid
          'is-valid'
        else
          'is-invalid'
      else
        ''

    div class: 'form-group row', [
      label
        class: "col-form-label #{changePasswordData.cols.left}"
        for: @idName
        @label
      div class: "input-group #{changePasswordData.cols.right}", [
        input
          id: @idName
          name: @fieldName
          class: "form-control #{validState}"
          type: if visible then 'text' else 'password'
          disabled: disabled
          placeholder: 'パスワードを入力'
          'aria-describedby': "#{@idName}-visible-button"
          onInput: [@setValue, targetValue]
        div class: 'input-group-append',
          div
            id: "#{@idName}-visible-button"
            class:
              "input-group-text #{if visible then 'text-primary' else ''}"
            onMouseDown: [@showPassword, true]
            onMouseUp: [@showPassword, false]
            onMouseLeave: [@showPassword, false]
            i
              class: "fas #{if visible then 'fa-eye' else 'fa-eye-slash'}"
              style: {width: '1em'}
        div class: 'valid-feedback', message
        div class: 'invalid-feedback', message
      ]
    ]

passwordCurrent = new PasswordInputGenerator
  name: 'password_current'
  label: '現在のパスワード'
  error: paramErrors['password_current']

password = new PasswordInputGenerator
  name: 'password'
  label: '新しいパスワード'
  error: paramErrors['password']

passwordConfirmation = new PasswordInputGenerator
  name: 'password_confirmation'
  label: 'パスワードの確認'
  error: paramErrors['password_confirmation']

SubmitButton = ({submitting, valid}) =>
  button
    class: 'btn btn-primary btn-block'
    type:'submit'
    disabled: submitting || !valid
    onClick: preventDefault (state) =>
      console.log state
      state
    '変更'



init =
  [passwordCurrent.camelName]: passwordCurrent.init()
  [password.camelName]: password.init()
  [passwordConfirmation.camelName]: passwordConfirmation.init()
  score: 0
  strength: 0
  valid: false
  submitting: false

checkPassword = (state) =>
  newState = {
    state...
    currentPassword: {state.currentpassword...}
    password: {state.password...}
    passwordConfirmation: {state.passwordConfirmation...}
  }

  result =
    if state.password.value?.length > 0
      if state.passwordCurrent.value?.length >0
        calcStrength(state.password.value, [state.passwordCurrent.value])
      else
        calcStrength(state.password.value)
    else
      {score: 0, strength: 0}

  newState.score = result.score
  newState.strength = result.strength

  newState =
    switch
      when not state.passwordCurrent.value?.length > 0
        passwordCurrent.setInvalid(newState, 'パスワードが空です。')
      else
        passwordCurrent.setValid(newState, '')

  newState =
    switch
      when not state.password.value?.length > 0
        password.setInvalid(newState, 'パスワードが空です。')

      when changePasswordData.config.unusable_chars?.length > 0 &&
          includeCharsInString(changePasswordData.config.unusable_chars,
            state.password.value)
        password.setInvalid(newState, '使用できない文字が含まれています。')

      when state.password.value.length < changePasswordData.config.min_size
        password.setInvalid(newState,
          '文字数が少なすぎます。' +
          "(#{changePasswordData.config.min_size}以上必須)")

      when state.password.value.length > changePasswordData.config.max_size
        password.setInvalid(newState,
          '文字数が多すぎます。' +
          "(#{changePasswordData.config.max_size}以下必須)")

      when changePasswordData.config.min_types > 1 &&
          countCharType(state.password.value) <
            changePasswordData.config.min_types
        password.setInvalid(newState, "文字の種類が少なすぎます。")

      when changePasswordData.config.min_score > 0 && result.score < changePasswordData.config.min_score
        password.setInvalid(newState, "パスワードが弱すぎます。")

      else
        password.setValid(newState, '')

  newState =
    switch
      when not state.passwordConfirmation.value?.length > 0
        passwordConfirmation.setInvalid(newState, 'パスワードが空です。')
      when state.password.value != state.passwordConfirmation.value
        passwordConfirmation.setInvalid(newState, 'パスワードが一致しません。')
      else
        passwordConfirmation.setValid(newState, '')
  {
    newState...
    valid: newState.passwordCurrent.valid &&
      newState.password.valid &&
      newState.passwordConfirmation.valid
  }

startSubmit: (state) => {
  state...
  submitting: true
}

stopSubmit: (state) => {
  state...
  submitting: false
}

inputErrorMessage: (messages) => (state, actions) =>
  for name, message of messages
    actions[camelize(name)].setInvalid(message)

view = (state) ->
  div [
    h passwordCurrent.view, {
      disabled: state.submitting
      state.passwordCurrent...
    }
    h password.view, {
      disabled: state.submitting
      state.password...
    }
    h StrengthIndicator, {
      score: state.score
      strength: state.strength
    }
    h passwordConfirmation.view, {
      disabled: state.submitting
      state.passwordConfirmation...
    }
    div class: 'row', [
      div class: "#{changePasswordData.cols.left}"
      div class: "#{changePasswordData.cols.right}",
        h SubmitButton,
          valid: state.valid
          submitting: state.submitting
    ]
  ]

app {init, view, node: changePasswordNode}

# changePasswordForm.onsubmit = (e) ->
#   formData = new FormData(e.target)
#
#   changePasswordApp.startSubmit()
#   alertMessage
#     info: 'パスワード変更処理を実行中です。しばらくお待ち下さい。'
#
#   changeAction = fetch changePasswordForm.action,
#     method: 'POST'
#     mode: 'same-origin'
#     credentials: 'same-origin'
#     headers:
#       'Accept': 'application/json'
#     body: formData
#
#   changeAction
#     .then (response) ->
#       data = await response.json()
#       if data.result == 'success'
#         alertMessage {
#           data.messages...
#           info: '約10秒後にトップページに戻ります。'
#         }
#         setTimeout ->
#           location.href = '/'
#         , 10 * 1000
#       else
#         alertMessage data.messages
#         changePasswordApp.inputErrorMessage(data.messages['param_errors'])
#         changePasswordApp.stopSubmit()
#     .catch (error) ->
#       console.warn error
#       alertMessage
#         error: "サーバー接続時にエラーが発生しました。: #{error}"
#       changePasswordApp.stopSubmit()
#
#   false
