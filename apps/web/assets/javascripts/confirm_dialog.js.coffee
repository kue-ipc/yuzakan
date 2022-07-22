# import {Modal} from './bootstrap.js'
import {text} from './hyperapp.js'
import * as html from './hyperapp-html.js'
# import {modalDialog} from './modal.js'

import ModalDialog from './modal_dialog.js'

export default class ConfirmDialog extends ModalDialog
  constructor: ({
    @confirmations = null
    @agreement_required = false
    ...props
  }) ->
    super props
    @value = true

  # overwrite
  modalBody: ({messages, confirmations, agreement_required, agreed}) ->
    [
      super({messages})
      if confirmations?
        [
          html.hr {}
          html.p {}, text if agreement_required
            '処理を実行する前に、下記全てを確認し、その内容について同意してください。'
          else
            '処理を実行する前に、下記全てを確認してください。'
          ul {}, confirmations.map (confirmation) ->
            li {}, text confirmation
        ]
      if agreement_required
        [
          html.hr {}
          html.div {class: 'form-check'}, [
            input {
              class: 'form-check-input', type: 'checkbox'
              value: agreed
              onchange: [changeAgree, !agreed]
            }
            label {class: 'form-check-label'},
              text '私は、上記全てについて同意します。'
          ]
        ]
    ].flat()

  changeAgree: (state, agreed) -> {state..., agreed}

  # overwrite
  initState: (state = {}) -> {
    confirmations: @confirmations
    agreement_required: @agreement_required
    agreed: false
    super(state)...
  }
