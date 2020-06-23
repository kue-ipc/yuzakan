import {h} from './hyperapp.js'
import {FaIcon} from './fa_icon.js'

export ModalHeader = ({labelId, title, closable}) =>
  titleProps = {class: 'modal-title'}
  titleProps.id = labelId if labelId?
  h 'div', class: 'modal-header',
    h 'h5', titleProps, title
    if closable
      h 'button',
        type: 'button',
        class: 'close',
        'data-dismiss': 'modal',
        'aria-label': '閉じる',
        h 'span', 'aria-hidden': 'true',
          h FaIcon, prefix: 'fas', name: 'fa-times'

export ModalBody = (_, children) =>
  h 'div', {class: 'modal-body'}, children

export ModalFooter = ({closable, button}) =>
  h 'div', class: 'modal-footer',
    if button
      h 'button',
        class: "btn btn-#{button.color}"
        type: 'button'
        onClick: button.onClick
        disabled: button.disabled
        button.label
    if closable
      h 'button',
        class: 'btn btn-secondary'
        type: 'button'
        'data-dismiss': 'modal'
        '閉じる'

export ModalDialog = ({modalSize, labelId, title, closable, button}, children) =>
  dialogClasses = ['modal-dialog', 'modal-dialog-centered', 'modal-dialog-scrollable']
  if modalSize
    dialogClasses.push("modal-#{modalSize}")
  h 'div', class: dialogClasses,
    h 'div', class: 'modal-content',
      h ModalHeader, {labelId, title, closable}
      h ModalBody, {}, children
      h ModalFooter, {closable, button}
