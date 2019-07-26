import './modern_browser.js'

import { h, app } from './hyperapp.js'
import zxcvbn from './zxcvbn.js'

import {listToField} from './string_utils.js'

changePasswordNode = document.getElementById('change-password')
chanegPasswordData = JSON.parse(changePasswordNode.getAttribute(
  'data-change-password'))

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
  {tag, label} =
    if score == 0 && strength == 0
      {tag: 'danger', label: ''}
    else
      SCORE_LABELS[score]

  strength = 100 if strength >= 100

  h 'div', class: 'row mb-3',
    h 'div', class: changePasswordData.cols.left
    h 'div', class: changePasswordData.cols.right,
      h 'div', class: 'progress', style: {height: '2em'},
        h 'div',
          class: "progress-bar bg-#{tag}",
          style: {width: "#{strength}%"}
          role: 'progressbar'
          'aria-valuenow': strength
          'aria-valuemin': '0'
          'aria-valuemax': '100'
          label

class PasswordInputGenerator
  constructor: ({@name, @label, error = null} ) ->
    @state =
      visible: false
      valid: false
      value: ''
      entered: false
    if error?
      Object.assign @state,
        wasValidated: true
        message: error

    @actions =
      showPassword: (value) =>
        visible: value
      resetValid: =>
        valid: false
        wasValidated: false
      setValid: (message) => (state) =>
        valid: true
        wasValidated: state.entered
        message: message
      setInvalid: (message) => (state) =>
        valid: false
        wasValidated: state.entered
        message: message
      setValue: (value) =>
        value: value
        entered: true

    @view = @createView()


  createView: ->
    nameList = [data.parents..., @name]
    idName = listToSnake(nameList...)
    fieldName = listToField(nameList...)

    ({visible, valid, wasValidated, message, showPassword, inputPassword}) =>
      vaildState = if wasValidated
        if valid
          'is-valid'
        else
          'is-invalid'

      h 'div', class: 'form-group row',
        h 'label',
          class: "col-form-label #{changePasswordData.cols.left}"
          for: idName
          @label
        h 'div', class: "input-group #{changePasswordData.cols.right}",
          h 'input',
            id: idName
            name: fieldName
            class: "form-control #{vaildState}"
            type: if visible then 'text' else 'password'
            placeholder: 'パスワードを入力'
            'aria-describedby': "#{idName}-visible-button"
            oninput: (e) => inputPassword(e.target.value)
          h 'div', class: 'input-group-append',
            h 'div',
              id: "#{idName}-visible-button"
              class:
                "input-group-text #{if visible then 'text-primary' else ''}"
              onmousedown: => showPassword(true)
              onmouseup: => showPassword(false)
              onmouseleave: => showPassword(false)
              h 'i',
                class: "fas #{if visible then 'fa-eye' else 'fa-eye-slash'}"
                style: {width: '1em'}
          h 'div', class: 'valid-feedback', message
          h 'div', class: 'invalid-feedback', message

passwordCurrent = new PasswordInputGenerator
  name: 'password-current'
  label: '現在のパスワード'
  error: paramErrors['password_current']

password = new PasswordInputGenerator
  name: 'password'
  label: '新しいパスワード'
  error: paramErrors['password']

passwordConfirmation = new PasswordInputGenerator
  name: 'password-confirmation'
  label: 'パスワードの確認'
  error: paramErrors['password_confirmation']

state =
  passwordCurrent: passwordCurrent.state
  password: password.state
  passwordConfirmation: passwordConfirmation.state
  score: 0
  strength: 0

actions =
  passwordCurrent: passwordCurrent.actions
  password: password.actions
  passwordConfirmation: passwordConfirmation.actions
  setScoreStrength: (value) =>
    score: value.score
    strength: value.strength
  checkPassword: => (state, actions) =>
    result =
      if state.password.value?.length > 0
        if state.passwordCurrent.value?.length >0
          calcStrength(state.password.value, [state.passwordCurrent.value])
        else
          calcStrength(state.password.value)
      else
        {score: 0, strength: 0}

    actions.setScoreStrength(result)

    switch
      when not state.passwordCurrent.value?.length > 0
        actions.passwordCurrent.setInvalid('パスワードが空です。')

      else
        actions.passwordCurrent.setValid('')

    switch
      when not state.password.value?.length > 0
        actions.password.setInvalid('パスワードが空です。')

      when changePasswordData.config.unusable_chars?.length > 0 &&
          includeCharsInString(changePasswordData.config.unusable_chars,
            state.password.value)
        actions.password.setInvalid('使用できない文字が含まれています。')

      when state.password.value.length < changePasswordData.config.min_size
        actions.password.setInvalid(
          '文字数が少なすぎます。' +
          "(#{changePasswordData.config.min_size}以上必須)")

      when state.password.value.length > changePasswordData.config.max_size
        actions.password.setInvalid(
          '文字数が多すぎます。' +
          "(#{changePasswordData.config.max_size}以下必須)")

      when changePasswordData.config.min_types > 1 &&
          countCharType(state.password.value) <
            changePasswordData.config.min_types
        actions.password.setInvalid("文字の種類が少なすぎます。")

      when changePasswordData.config.min_score > 0 && result.score < changePasswordData.config.min_score
        actions.password.setInvalid("パスワードが弱すぎます。")

      else
        actions.password.setValid('')

    switch
      when not state.passwordConfirmation.value?.length > 0
        actions.passwordConfirmation.setInvalid('パスワードが空です。')
      when state.password.value != state.passwordConfirmation.value
        actions.passwordConfirmation.setInvalid('パスワードが一致しません。')
      else
        actions.passwordConfirmation.setValid('')

view = (state, actions) ->
  h 'div', {} , [
    h passwordCurrent.view, {
      inputPassword: (text) ->
        actions.passwordCurrent.setValue(text)
        actions.checkPassword()
      state.passwordCurrent...
      actions.passwordCurrent...
    }
    h password.view, {
      inputPassword: (text) ->
        actions.password.setValue(text)
        actions.checkPassword()
      state.password...
      actions.password...
    }
    h StrengthIndicator, {
      score: state.score
      strength: state.strength
    }
    h passwordConfirmation.view, {
      inputPassword: (text) ->
        actions.passwordConfirmation.setValue(text)
        actions.checkPassword()
      state.passwordConfirmation...
      actions.passwordConfirmation...
    }
    h 'div', class: 'row',
      h 'div', class: "#{changePasswordData.cols.left}"
      h 'div', class: "#{changePasswordData.cols.right}",
        if state.passwordCurrent.valid &&
            state.password.valid &&
            state.passwordConfirmation.valid
          h 'button', class: 'btn btn-primary btn-block', type:'submit', '変更'
        else
          h 'button', class: 'btn btn-primary btn-block', type:'submit', disabled: true, '変更'
  ]

app state, actions, view, changePasswordNode
