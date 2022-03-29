import {Modal} from './bootstrap.js'
import {app, text} from './hyperapp.js?=0.6.0'
import * as html from './hyperapp-html.js'
import {modalDialog} from './modal.js'

export default class ConfirmDialog
  MESSAGE_EVENT = 'confirmdialog.message'

  constructor: ({
    @id
    @status = 'info'
    @title
    @message
    @confirmations = null
    @agreement_required = false
    action = {}
    close = {}
  }) ->
    @action = {
      color: 'primary'
      label: 'OK'
      side: 'right'
      action...
    }
    @close = {
      color: 'secondary'
      label: 'キャンセル'
      close...
    }

    @modalNode = document.createElement('div')
    @modalNode.id = "#{@id}-modal"
    @modalNode.classList.add('modal', 'fade')
    @modalNode.setAttribute('tabindex', -1)
    @modalNode.setAttribute('aria-hidden', 'true')

    modalDialogNode = document.createElement('div')
    modalDialogNode.id = "#{@id}-modal-dialog"
    modalDialogNode.classList.add('modal-dialog', 'modal-dialog-centered')

    @modalNode.appendChild(modalDialogNode)
    document.body.appendChild(@modalNode)

    @modal = new Modal(@modalNode)

    app {
      init: {
        status: 'unknown'
        title: 'no title'
        messages: 'n/a'
        closable: true
        link: null
        reload: false
      }
      view: @modalView
      node: modalDialogNode
      subscriptions: (state) => [
        @messageSub @messageAction, {node: @modalNode}
      ]
    }

  modalView: ({status, title, action, close, agreement_required, agreed, ...props}) =>
    modalDialog {
      id: @id,
      status
      title
      closable: true
      action:
        {
          action...
          disbaled: agreement_required && !agreed
          onclick: (state) =>
            @result = true
            @modal.hide()
            state
        }
      close: @close
    }, @modalBody {agreement_required, agreed, props...}

  modalBody: ({message, confirmations, agreement_required, agreed}) ->
    html.div {}, [
      html.p {}, text message
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
              onchange: (state, event) -> {state..., agreed: event.target.value}
            }
            label {class: 'form-check-label'},
              text '私は、上記全てについて同意します。'
          ]
        ]
    ].flat()

  modalMessage: (state) ->
    event = new CustomEvent(ConfirmDialog.MESSAGE_EVENT, {detail: state})
    @modalNode.dispatchEvent(event)

  messageRunner: (dispatch, {action, node}) ->
    func = (e) -> dispatch(action, e.detail)
    node.addEventListener(ConfirmDialog.MESSAGE_EVENT, func)
    -> node.removeEventListener(ConfirmDialog.MESSAGE_EVENT, func)

  messageSub: (action, {node}) => [@messageRunner, {action, node}]

  messageAction: (state, params) =>
    newState = {state..., params...}
    [newState, focus("#{@id}-modal-close-button")]

  confirmPromise: ({
    status = @status
    title = @title
    message = @message
    confirmations = @confirmations
    agreement_required = @agreement_required
    action = @action
    close = @close
  } = {}) ->
    @modalMessage({
      status
      title
      message
      confirmations
      agreement_required
      action
      close
      agreed: false
    })
    @result = false
    @modal.show()

    await @waitModalClose()

    return @result

  waitModalClose: =>
    new Promise (resolve, reject) =>
      @modalNode.addEventListener 'hidden.bs.modal', ->
        resolve()
      , {once: true}
