import './modern_browser.js'

import { h, app } from './hyperapp.js'
import zxcvbn from './zxcvbn.js'

changePasswordNode = document.getElementById('change-password')

parentName = changePasswordNode.getAttribute('data-name')
config = JSON.parse(changePasswordNode.getAttribute('data-config'))
dataCols = JSON.parse(changePasswordNode.getAttribute('data-cols'))

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
  result = zxcvbn(str, [dict..., config.dict...])
  {
    score: result.score
    strength: result.guesses_log10 * 7
  }

StrengthIndicator = ({score, strength, cols}) =>
  {tag, label} =
    if score == 0 && strength == 0
      {tag: 'danger', label: ''}
    else
      SCORE_LABELS[score]

  strength = 100 if strength >= 100

  h 'div', class: 'row mb-3', [
    h 'div', class: cols.left
    h 'div', class: cols.right,
      h 'div', class: 'progress', style: {height: "2em"} ,
        h 'div', {
          class: "progress-bar bg-#{tag}",
          style:
            width: "#{strength}%"
          role: 'progressbar'
          'aria-valuenow': strength
          'aria-valuemin': '0'
          'aria-valuemax': '100'
        } , label
  ]

class PasswordInputGenerator
  constructor: ({@name, @label, parentName, error = null} ) ->
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

    @fieldName =
      if parentName
        "#{parentName}[#{@name.replace('-', '_')}]"
      else
        @name.replace('-', '_')

  createView: ->
    ({visible, valid, wasValidated, message, showPassword, inputPassword,
        cols} ) =>
      vaildState = if wasValidated
        if valid
          'is-valid'
        else
          'is-invalid'

      h 'div', class: 'form-group row', [
        h 'label', class: "col-form-label #{cols.left}", for: @name, @label
        h 'div', class: "input-group #{cols.right}", [
          h 'input', {
            id: @name
            name: @fieldName
            class: "form-control #{vaildState}"
            type: if visible then 'text' else 'password'
            placeholder: "パスワードを入力"
            'aria-describedby': "#{@name}-visible-button"
            oninput: (e) =>
              inputPassword(e.target.value)
          }
          h 'div', class: 'input-group-append',
            h 'div', {
              id: "#{@name}-visible-button"
              class: "input-group-text #{if visible then 'text-primary' else ''}"
              onmousedown: => showPassword(true)
              onmouseup: => showPassword(false)
              onmouseleave: => showPassword(false)
            } ,
              h 'i', {
                class: "fas #{if visible then 'fa-eye' else 'fa-eye-slash'}"
                style:
                  width: '1em'
              } , ''
          h 'div', class: 'valid-feedback', message
          h 'div', class: 'invalid-feedback', message
        ]
      ]

passwordCurrent = new PasswordInputGenerator
  name: 'password-current'
  label: '現在のパスワード'
  parentName: parentName
  error: paramErrors['password_current']

password = new PasswordInputGenerator
  name: 'password'
  label: '新しいパスワード'
  parentName: parentName
  error: paramErrors['password']

passwordConfirmation = new PasswordInputGenerator
  name: 'password-confirmation'
  label: 'パスワードの確認'
  parentName: parentName
  error: paramErrors['password_confirmation']

state =
  passwordCurrent: passwordCurrent.state
  password: password.state
  passwordConfirmation: passwordConfirmation.state
  score: 0
  strength: 0
  cols: dataCols

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
      when config.unusable_chars?.length > 0 &&
          includeCharsInString(config.unusable_chars, state.password.value)
        actions.password.setInvalid('使用できない文字が含まれています。')
      when state.password.value.length < config.min_size
        actions.password.setInvalid("文字数が少なすぎます。(#{config.min_size}以上必須)")
      when state.password.value.length > config.max_size
        actions.password.setInvalid("文字数が多すぎます。(#{config.max_size}以下必須)")
      when config.min_types > 1 &&
          countCharType(state.password.value) < config.min_types
        actions.password.setInvalid("文字の種類が少なすぎます。")
      when config.min_score > 0 && result.score < config.min_score
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
      cols: state.cols
      state.passwordCurrent...
      actions.passwordCurrent...
    }
    h password.view, {
      inputPassword: (text) ->
        actions.password.setValue(text)
        actions.checkPassword()
      cols: state.cols
      state.password...
      actions.password...
    }
    h StrengthIndicator, {
      score: state.score
      strength: state.strength
      cols: state.cols
    }
    h passwordConfirmation.view, {
      inputPassword: (text) ->
        actions.passwordConfirmation.setValue(text)
        actions.checkPassword()
      cols: state.cols
      state.passwordConfirmation...
      actions.passwordConfirmation...
    }
    h 'div', class: 'row',
      h 'div', class: "#{state.cols.left}"
      h 'div', class: "#{state.cols.right}",
        if state.passwordCurrent.valid &&
            state.password.valid &&
            state.passwordConfirmation.valid
          h 'button', class: 'btn btn-primary btn-block', type:'submit', '変更'
        else
          h 'button', class: 'btn btn-primary btn-block', type:'submit', disabled: true, '変更'
  ]

app state, actions, view, changePasswordNode
