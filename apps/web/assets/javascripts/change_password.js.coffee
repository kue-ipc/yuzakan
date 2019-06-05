import { h, app } from './hyperapp.js'
import zxcvbn from './zxcvbn.js'

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

StrengthIndicator = ({ strength, colSize }) =>
  [bgColor, label] = switch
    when strength >= 100 then ['bg-success', '非常に強い']
    when strength >= 80 then ['bg-success', '十分強い']
    when strength >= 60 then ['bg-info', '強い']
    when strength >= 30 then ['bg-warning', '弱い']
    when strength > 0 then ['bg-danger', 'とても弱い']
    else ['bg-danger']
  if strength >= 100
    strength = 100
  h 'div', class: 'row mb-3', [
    h 'div', class: colSize(0)
    h 'div', class: colSize(1),
      h 'div', class: 'progress', style: {height: "2em"},
        h 'div', {
          class: "progress-bar #{bgColor}",
          style:
            width: "#{strength}%"
          role: 'progressbar'
          'aria-valuenow': strength
          'aria-valuemin': '0'
          'aria-valuemax': '100'
        }, label
  ]

class PasswordInputGenerator
  constructor: ({@name, @label}) ->
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

  createView: ->
    ({visible, valid, wasValidated, message,
      showPassword, inputPassword, colSize}) =>
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
            class: "form-control #{vaildState}"
            type: if visible then 'text' else 'password'
            placeholder: "パスワードを入力"
            'aria-describedby': "#{@name}-visible-button"
            oninput: (e) =>
              inputPassword(e.target.value)
            required: true
          }
          h 'div', class: "input-group-append",
            h 'span', {
              id: "#{@name}-visible-button"
              class: "input-group-text #{if visible then 'text-primary' else ''}"
              onmousedown: => showPassword(true)
              onmouseup: => showPassword(false)
              onmouseleave: => showPassword(false)
            },
              h 'i'
                class: "fas #{if visible then 'fa-eye' else 'fa-eye-slash'}"
                style:
                  width: '1em'
          h 'div', class: 'valid-feedback', message
          h 'div', class: 'invalid-feedback', message
        ]
      ]

currentPassword = new PasswordInputGenerator
  name: 'current-password'
  label: '現在のパスワード'
newPassword = new PasswordInputGenerator
  name: 'new-password'
  label: '新しいパスワード'
confirmPassword = new PasswordInputGenerator
  name: 'confirm-password'
  label: 'パスワードの確認'

state =
  currentPassword: currentPassword.state
  newPassword: newPassword.state
  confirmPassword: confirmPassword.state
  strength: 0

actions =
  currentPassword: currentPassword.actions
  newPassword: newPassword.actions
  confirmPassword: confirmPassword.actions
  setStrength: (value) =>
    strength: value

cs = new ColSizer
colSize = (idecies) -> cs.colSize(idecies)

view = (state, actions) ->
  h 'div', {}, [
    h currentPassword.view, {
      inputPassword: (text) ->
        if text
          actions.currentPassword.setValid('')
        else
          actions.currentPassword.setInvalid('パスワードが空です')
      colSize: colSize
      state.currentPassword...
      actions.currentPassword...
    }
    h newPassword.view, {
      inputPassword: (text) ->
        if text
          score = zxcvbn(text).guesses_log10 * 10
          actions.setStrength(score)
          if score >= 60
            actions.newPassword.setValid('強いパスワードです。')
          else
            actions.newPassword.setInvalid('弱いパスワードです。')
          confirmText = document.getElementById('confirm-password').value
          if confirmText
            if text == confirmText
              actions.confirmPassword.setValid('一致します。')
            else
              actions.confirmPassword.setInvalid('一致しません。')
        else
          actions.setStrength(0)
          actions.newPassword.setInvalid('パスワードが空です')
      colSize: colSize
      state.newPassword...
      actions.newPassword...
    }
    h StrengthIndicator, strength: state.strength, colSize: colSize
    h confirmPassword.view, {
      inputPassword: (text) ->
        if text == ''
          actions.confirmPassword.setInvalid('パスワードが空です')
        else
          if text == document.getElementById('new-password').value
            actions.confirmPassword.setValid('一致します。')
          else
            actions.confirmPassword.setInvalid('一致しません。')
      colSize: colSize
      state.confirmPassword...
      actions.confirmPassword...
    }
    h 'button', class: 'btn btn-primary', type:'submit', '送信'
  ]

app state, actions, view, document.getElementById('change-password')
