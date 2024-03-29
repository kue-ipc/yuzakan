import {Modal} from 'bootstrap'
import {app, text} from 'hyperapp'
import * as html from '@hyperapp/html'
import {modalDialog} from '~/app/modal.js'

export default class InputTextDialog
  MESSAGE_EVENT = 'inputtextdialog.message'

  constructor: ({
    @id
    @title
    @messages = []
    @siza
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
    modalDialogNode.classList.add('modal-dialog')

    @modalNode.appendChild(modalDialogNode)
    document.body.appendChild(@modalNode)

    @modal = new Modal(@modalNode)

    app {
      init: {
        title: @title
        messages: @messages
        value: ''
        size: @size
        action: @action
        close: @close
      }
      view: @modalView
      node: modalDialogNode
      subscriptions: (state) => [
        @messageSub @messageAction, {node: @modalNode}
        @shownSub (state) -> {state..., shown: true}
        @hiddenSub (state) -> {state..., shown: false}
      ]
    }

  modalView: ({title, messages, value, size, action, close, shown}) =>
    modalDialog {
      id: @id,
      size: 'lg'
      centered: true
      title
      closable: true
      action:
        {
          action...
          onclick: (state) =>
            @result = value
            @modal.hide()
            {state..., value: ''}
        }
      close: @close
    }, @modalBody {messages, value, size, shown}

  modalBody: ({messages, value, size, shown}) ->
    html.div {},
      if shown
        [
          (html.p({}, text message) for message in messages)...
          html.textarea {
            id: "#{@id}-input-textarea"
            class: 'form-control'
            maxlength: size
            rows: 10
            oninput: (state, event) -> {state..., value: event.target.value}
          }, text value
        ]
      else
        html.p {}, text '...'

  fireModalMessage: (state) ->
    event = new CustomEvent(InputTextDialog.MESSAGE_EVENT, {detail: state})
    @modalNode.dispatchEvent(event)

  messageRunner: (dispatch, {action, node}) ->
    func = (e) -> dispatch(action, e.detail)
    node.addEventListener(InputTextDialog.MESSAGE_EVENT, func)
    -> node.removeEventListener(InputTextDialog.MESSAGE_EVENT, func)

  messageSub: (action, {node}) => [@messageRunner, {action, node}]

  messageAction: (state, params) =>
    [{state..., params...}, focus("#{@id}-input-textarea")]

  shownRunner: (dispatch, {action}) =>
    func = -> dispatch(action)
    @modalNode.addEventListener('shown.bs.modal', func)
    => @modalNode.removeEventListener('shown.bs.modal', func)

  shownSub: (action) => [@shownRunner, {action}]

  hiddenRunner: (dispatch, {action}) =>
    func = -> dispatch(action)
    @modalNode.addEventListener('hidden.bs.modal', func)
    => @modalNode.removeEventListener('hidden.bs.modal', func)

  hiddenSub: (action) => [@hiddenRunner, {action}]

  inputPromise: ({messages, value}) ->
    @fireModalMessage({messages, value})
    @result = null
    @modal.show()

    await @waitModalClose()

    return @result

  waitModalClose: =>
    new Promise (resolve, reject) =>
      @modalNode.addEventListener 'hidden.bs.modal', ->
        resolve()
      , {once: true}
