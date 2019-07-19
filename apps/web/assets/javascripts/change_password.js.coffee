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
  {tag: 'warning', label: '弱い'}
  {tag: 'secondary', label: '少し弱い'}
  {tag: 'info', label: '強い'}
  {tag: 'success', label: '安全'}
]

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
      if error?
        visible: false
        valid: false
        wasValidated: true
        message: error
      else
        visible: false
        valid: false
        wasValidated: false
        message: 'パスワードを入力してください。'

    @actions =
      showPassword: (value) => (state, actions) =>
        visible: value
      resetValid: =>
        wasValidated: false
      setValid: (message) =>
        valid: true
        wasValidated: true
        message: message
      setInvalid: (message) =>
        valid: false
        wasValidated: true
        message: message

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
            required: true
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

newPassword = new PasswordInputGenerator
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
  newPassword: newPassword.state
  passwordConfirmation: passwordConfirmation.state
  score: 0
  strength: 0
  cols: dataCols

actions =
  passwordCurrent: passwordCurrent.actions
  newPassword: newPassword.actions
  passwordConfirmation: passwordConfirmation.actions
  setScoreStrength: (value) =>
    score: value.score
    strength: value.strength

view = (state, actions) ->
  h 'div', {} , [
    h passwordCurrent.view, {
      inputPassword: (text) ->
        if text
          actions.passwordCurrent.setValid('')
        else
          actions.passwordCurrent.setInvalid('パスワードが空です')
      cols: state.cols
      state.passwordCurrent...
      actions.passwordCurrent...
    }
    h newPassword.view, {
      inputPassword: (text) ->
        if text
          result = zxcvbn(text)
          actions.setScoreStrength
            score: result.score
            strength: result.guesses_log10 * 7
          if result.score >= config.min_score
            actions.newPassword.setValid('強いパスワードです。')
          else
            actions.newPassword.setInvalid('弱いパスワードです。')
          confirmText = document.getElementById(passwordConfirmation.name).value
          if confirmText
            if text == confirmText
              actions.passwordConfirmation.setValid('一致します。')
            else
              actions.passwordConfirmation.setInvalid('一致しません。')
        else
          actions.setScoreStrength(score: 0, strength: 0)
          actions.newPassword.setInvalid('パスワードが空です')
      cols: state.cols
      state.newPassword...
      actions.newPassword...
    }
    h StrengthIndicator, {
      score: state.score
      strength: state.strength
      cols: state.cols
    }
    h passwordConfirmation.view, {
      inputPassword: (text) ->
        if text == ''
          actions.passwordConfirmation.setInvalid('パスワードが空です')
        else
          if text == document.getElementById(newPassword.name).value
            actions.passwordConfirmation.setValid('一致します。')
          else
            actions.passwordConfirmation.setInvalid('一致しません。')
      cols: state.cols
      state.passwordConfirmation...
      actions.passwordConfirmation...
    }
    h 'div', class: 'row',
      h 'div', class: "#{state.cols.left}"
      h 'div', class: "#{state.cols.right}",
        if state.passwordCurrent.valid &&
            state.newPassword.valid &&
            state.passwordConfirmation.valid
          h 'button', class: 'btn btn-primary btn-block', type:'submit', '変更'
        else
          h 'button', class: 'btn btn-primary btn-block', type:'submit', disabled: true, '変更'
  ]

app state, actions, view, changePasswordNode
