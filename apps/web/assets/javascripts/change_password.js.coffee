import { h, app } from './hyperapp.js'
import zxcvbn from './zxcvbn.js'

changePasswodNode = document.getElementById('change-password')
parentName = changePasswodNode.getAttribute('data-name')
config = JSON.parse(changePasswodNode.getAttribute('data-config'))

class ColSizer
  @colNames = ['sm', 'md', 'lg', 'xl']

  constructor: ->
    @cols =
      sm: [4, 8, 12]
      md: [3, 6, 3]
      lg: [2, 4, 6]
      xl: [2, 4, 6]

  colSize: (indices...) ->
    list = for name in ColSizer.colNames
      size = (@cols[name][idx] for idx in indices).reduce((a, b) -> a + b)
      ['col', name, size.toString()].join('-')
    list.join(' ')

StrengthIndicator = ({ score, strength, colSize } ) =>
  [bgColor, label] =
    if score >= config.min_score
      ['bg-success', '強い']
    else if score > 0
      ['bg-warning', '弱い']
    else if strength > 0
      ['bg-danger', '危険']
    else
      ['bg-danger']

  strength = 100 if strength >= 100
  h 'div', class: 'row mb-3', [
    h 'div', class: colSize(0)
    h 'div', class: colSize(1),
      h 'div', class: 'progress', style: {height: "2em"} ,
        h 'div', {
          class: "progress-bar #{bgColor}",
          style:
            width: "#{strength}%"
          role: 'progressbar'
          'aria-valuenow': strength
          'aria-valuemin': '0'
          'aria-valuemax': '100'
        } , label
  ]

class PasswordInputGenerator
  constructor: ({@name, @label, parentName} ) ->
    @state =
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
    ({visible, valid, wasValidated, message,
      showPassword, inputPassword, colSize} ) =>
      vaildState = if wasValidated
        if valid
          'is-valid'
        else
          'is-invalid'

      h 'div', class: 'form-group row', [
        h 'label', class: "col-form-label #{colSize(0)}", for: @name, @label
        h 'div', class: "input-group #{colSize(1)}", [
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
newPassword = new PasswordInputGenerator
  name: 'password'
  label: '新しいパスワード'
  parentName: parentName
passwordConfirmation = new PasswordInputGenerator
  name: 'password-confirmation'
  label: 'パスワードの確認'
  parentName: parentName

state =
  passwordCurrent: passwordCurrent.state
  newPassword: newPassword.state
  passwordConfirmation: passwordConfirmation.state
  score: 0
  strength: 0

actions =
  passwordCurrent: passwordCurrent.actions
  newPassword: newPassword.actions
  passwordConfirmation: passwordConfirmation.actions
  setScoreStrength: (value) =>
    score: value.score
    strength: value.strength

cs = new ColSizer
colSize = (idecies) -> cs.colSize(idecies)


view = (state, actions) ->
  h 'div', {} , [
    h passwordCurrent.view, {
      inputPassword: (text) ->
        if text
          actions.passwordCurrent.setValid('')
        else
          actions.passwordCurrent.setInvalid('パスワードが空です')
      colSize: colSize
      state.passwordCurrent...
      actions.passwordCurrent...
    }
    h newPassword.view, {
      inputPassword: (text) ->
        if text
          result = zxcvbn(text)
          actions.setScoreStrength
            score: result.score
            strength: result.guesses_log10 * 10
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
      colSize: colSize
      state.newPassword...
      actions.newPassword...
    }
    h StrengthIndicator, score: state.score, strength: state.strength, colSize: colSize
    h passwordConfirmation.view, {
      inputPassword: (text) ->
        if text == ''
          actions.passwordConfirmation.setInvalid('パスワードが空です')
        else
          if text == document.getElementById(newPassword.name).value
            actions.passwordConfirmation.setValid('一致します。')
          else
            actions.passwordConfirmation.setInvalid('一致しません。')
      colSize: colSize
      state.passwordConfirmation...
      actions.passwordConfirmation...
    }
    h 'div', class: 'row',
      h 'div', class: "#{colSize(0)}"
      h 'div', class: "#{colSize(1)}",
        if state.passwordCurrent.valid &&
            state.newPassword.valid &&
            state.passwordConfirmation.valid
          h 'button', class: 'btn btn-primary', type:'submit', '送信'
        else
          h 'button', class: 'btn btn-primary', type:'submit', disabled: true, '送信'
  ]

app state, actions, view, changePasswodNode
