import './modern_browser.js'

import {h, text, app} from './hyperapp.js'
import {FaIcon} from './fa_icon.js'
import zxcvbn from './zxcvbn.js'

import {listToField, listToKebab, camelize} from './string_utils.js'
import WebPostJson from './web_post_json.js'

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

  h 'div', class: 'row mb-3', [
    h 'div', class: changePasswordData.cols.left
    h 'div', class: changePasswordData.cols.right,
      h 'div', class: 'progress', style: {height: '2em'},
        h 'div',
          class: "progress-bar bg-#{scoreLabel.tag}",
          style: {width: "#{strength}%"}
          role: 'progressbar'
          'aria-valuenow': strength
          'aria-valuemin': '0'
          'aria-valuemax': '100'
          text scoreLabel.label
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

  showPassword: (state, {visible}) => {
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

  setValue: (state, {value}) =>
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

    h 'div', class: 'form-group row', [
      h 'label',
        class: "col-form-label #{changePasswordData.cols.left}"
        for: @idName
        text @label
      h 'div', class: "input-group #{changePasswordData.cols.right}", [
        h 'input',
          id: @idName
          name: @fieldName
          class: "form-control #{validState}"
          type: if visible then 'text' else 'password'
          disabled: disabled
          placeholder: 'パスワードを入力'
          'aria-describedby': "#{@idName}-visible-button"
          oninput: (_, event) => [@setValue, {value: event.target.value}]
        h 'div', class: 'input-group-append',
          h 'div',
            id: "#{@idName}-visible-button"
            class:
              "input-group-text #{if visible then 'text-primary' else ''}"
            onmousedown: [@showPassword, {visible: true}]
            onmouseup: [@showPassword, {visible: false}]
            onmouseleave: [@showPassword, {visible: false}]
            FaIcon
              prefix: 'fas'
              name: if visible then 'fa-eye' else 'fa-eye-slash'
        h 'div', class: 'valid-feedback',
          text message
        h 'div', class: 'invalid-feedback',
          text message
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

passwordInputs = {
  passwordCurrent
  password
  passwordConfirmation
}

SubmitButton = ({submitting, valid}) =>
  h 'button',
    class: 'btn btn-primary btn-block'
    type:'submit'
    disabled: submitting || !valid
    onclick: (state, event) =>
      event.preventDefault()
      [
        startSubmit(state)
        [submitRunner]
      ]
    text '変更'

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
    passwordCurrent: {state.passwordCurrent...}
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

startSubmit = (state) => {
  state...
  submitting: true
}

stopSubmit = (state, messages) =>
  for error in messages['errors']
    if typeof error == 'object'
      for name, message of error
          state = passwordInputs[camelize(name)].setInvalid(state, message)
  {
    state...
    submitting: false
  }

webPost = new WebPostJson
  form: changePasswordForm
  title: 'パスワード変更'
  messages: {
    running: 'パスワード変更を実行しています。しばらくお待ち下さい。'
    success: '約10秒後にトップページに戻ります。'
  }
  successLink: '/dashboard'
  reloadTime: 10 * 1000

submitRunner = (dispatch) ->
  (->
    try
      {result, messages} = await webPost.submitPromise()
      if result != 'success'
        dispatch(stopSubmit, messages)
    catch error
      console.log(error)
      dispatch(stopSubmit, {})
  )()

view = (state) ->
  h 'div', {}, [
    passwordCurrent.view {
      disabled: state.submitting
      state.passwordCurrent...
    }
    password.view {
      disabled: state.submitting
      state.password...
    }
    StrengthIndicator {
      score: state.score
      strength: state.strength
    }
    passwordConfirmation.view {
      disabled: state.submitting
      state.passwordConfirmation...
    }
    h 'div', class: 'row', [
      h 'div', class: "#{changePasswordData.cols.left}"
      h 'div', class: "#{changePasswordData.cols.right}",
        SubmitButton
          valid: state.valid
          submitting: state.submitting
    ]
  ]

app {init, view, node: changePasswordNode}
