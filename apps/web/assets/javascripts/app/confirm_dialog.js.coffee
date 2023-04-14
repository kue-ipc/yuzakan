import {text} from '~/vendor/hyperapp.js'
import * as html from '~/vendor/hyperapp-html.js'

import ModalDialog from '~/app/modal_dialog.js'

export default class ConfirmDialog extends ModalDialog
  constructor: ({
    @confirmations = null
    @agreement_required = false
    ...props
  }) ->
    super props
    @value = true

  # override
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

  # override
  initState: (state = {}) -> {
    confirmations: @confirmations
    agreement_required: @agreement_required
    agreed: false
    super(state)...
  }
