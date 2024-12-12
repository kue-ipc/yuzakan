import {text} from 'hyperapp'
import * as html from '@hyperapp/html'
import {StatusIcon} from '~/app/status.js'

export modalHeader = ({id, title, status, closable}) ->
  titleProps = {class: 'modal-title'}
  titleProps.id = labelId if labelId?

  html.div {id: "#{id}-modal-header", class: 'modal-header'}, [
    html.h5 {id: "#{id}-modal-title", class: 'modal-title d-flex align-items-center'}, [
      StatusIcon {status, class: 'flex-shrink-0 me-2'} if status
      html.div {}, text title
    ]
    if closable then html.button {
      id: "#{id}-modal-header-close"
      class: 'btn-close',
      type: 'button',
      'data-bs-dismiss': 'modal',
      'aria-label': '閉じる'
    }
  ]

export modalBody = ({id}, children) ->
  html.div {id: "#{id}-modal-body", class: 'modal-body'}, children

export modalFooter = ({id, closable, action, close}) ->
  buttons = [
    if closable then html.button {
      id: "#{id}-modal-close-button"
      class: "btn btn-#{close?.color || 'secondary'}"
      type: 'button'
      'data-bs-dismiss': 'modal'
    }, text close?.label || '閉じる'
    if action? then html.button {
      id: "#{id}-modal-action-button"
      class: "btn btn-#{action.color}"
      type: 'button'
      onclick: action.onclick
      disabled: action.disabled
    }, text action.label
  ]
  buttons = buttons.reverse() if action?.side == 'left'
  html.div {id: "#{id}-modal-footer", class: 'modal-footer'}, buttons

export modalContent = ({id, title, status, closable, action, close}, children) ->
  html.div {class: 'modal-content'}, [
    modalHeader {id, title, status, closable}
    modalBody {id}, children
    modalFooter {id, closable, action, close} if closable || action?
  ]

export modalDialog = ({id, scrollable, centered, size, fullscreen, props...}, children) ->
  dialogClasses = [
    'modal-dialog'
    'modal-dialog-scrollable' if scrollable
    'modal-dialog-centered' if centered
    "modal-#{size}" if size
    if fullscreen
      if typeof fullscreen == 'string'
        "modal-fullscreen-#{fullscreen}"
      else
        'modal-fullscreen'
  ]

  html.div {id: "#{id}-modal-dialog", class: dialogClasses},
    modalContent {id, props...}, children
