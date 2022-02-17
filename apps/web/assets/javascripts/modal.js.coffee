import {h, text} from './hyperapp.js?v=0.6.0'
import {div, h5, button} from './hyperapp-html.js?v=0.6.0'
import {StatusIcon} from './status.js?v=0.6.0'

export modalHeader = ({id, title, status, closable}) ->
  titleProps = {class: 'modal-title'}
  titleProps.id = labelId if labelId?

  div {id: "#{id}-modal-header", class: 'modal-header'}, [
    h5 {id: "#{id}-modal-title", class: 'modal-title'}, [
      StatusIcon {status} if status
      text title
    ]
    if closable then button {
      id: "#{id}-modal-header-close"
      class: 'btn-close',
      type: 'button',
      'data-bs-dismiss': 'modal',
      'aria-label': '閉じる'
    }
  ]

export modalBody = ({id}, children) ->
  div {id: "#{id}-modal-body", class: 'modal-body'}, children

export modalFooter = ({id, closable, action}) ->
  div {id: "#{id}-modal-footer", class: 'modal-footer'}, [
    if closable then button {
      id: "#{id}-modal-close-button"
      class: 'btn btn-secondary'
      type: 'button'
      'data-bs-dismiss': 'modal'
    }, text '閉じる'
    if action? then button {
      id: "#{id}-modal-action-button"
      class: "btn btn-#{action.color}"
      type: 'button'
      onclick: action.onclick
      disabled: button.disabled
    }, text action.label
  ]

export modalContent = ({id, title, status, closable, action}, children) ->
  div {class: 'modal-content'}, [
    modalHeader {id, title, status, closable}
    modalBody {id}, children
    modalFooter {id, closable, action} if closable || action?
  ]

export modalDialog = ({id, size, scrollable, centered, props...}, children) ->
  dialogClasses = [
    'modal-dialog'
    'modal-dialog-scrollable' if scrollable
    'modal-dialog-centered' if centered
    "modal-#{size}" if size
  ].filter (v) -> v?

  div {id: "#{id}-modal-dialog", class: dialogClasses},
    modalContent {id, props...}, children
