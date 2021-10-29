import {h, text} from './hyperapp.js'
import {FaIcon} from './fa_icon.js'

export ModalHeader = ({labelId, title, closable}) =>
  titleProps = {class: 'modal-title'}
  titleProps.id = labelId if labelId?
  h 'div', class: 'modal-header', [
    h 'h5', titleProps,
      text title
    if closable then h 'button',
      type: 'button',
      class: 'btn-close',
      'data-bs-dismiss': 'modal',
      'aria-label': '閉じる'
  ]

export ModalBody = (_, children) =>
  h 'div', {class: 'modal-body'}, children

export ModalFooter = ({closable, button}) =>
  h 'div', class: 'modal-footer',
    if button then h 'button',
      class: "btn btn-#{button.color}"
      type: 'button'
      onClick: button.onClick
      disabled: button.disabled
      text button.label
    if closable then h 'button',
      class: 'btn btn-secondary'
      type: 'button'
      'data-bs-dismiss': 'modal'
      text '閉じる'

export ModalDialog = ({modalSize, labelId, title, closable, button}, children) =>
  dialogClasses = ['modal-dialog', 'modal-dialog-centered', 'modal-dialog-scrollable']
  if modalSize
    dialogClasses.push("modal-#{modalSize}")

  h 'div', class: dialogClasses,
    h 'div', class: 'modal-content', [
      ModalHeader {labelId, title, closable}
      ModalBody {}, children
      ModalFooter {closable, button}
    ]