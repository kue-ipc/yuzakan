# プロバイダーのパラメーター

import {h, text, app} from '../hyperapp.js?v=0.6.0'
import {fieldName, fieldId} from '../form_helper.js?v=0.6.0'
import {h5, div, small, label, input, textarea, select, option} from '../hyperapp-html.js?v=0.6.0'

parentNames = ['provider', 'params']

inputControl = (props) ->
  name = fieldName(props.name, parentNames)
  id = fieldId(props.name, parentNames)
  describeId = "#{id}-help"

  inputOpts = {
    id: id
    name: name
    type: props.inputType
    class: 'form-control'
    value: props.value ? (if props.encrypted? then props.default else '')
    'aria-edscribedby': describeId
  }

  for key in [
    'required', 'placeholder', 'maxlength', 'minlength', 'pattern', 'size'
     'max', 'min', 'step'
  ]
    inputOpts[key] = props[key] if props[key]?

  div {class: 'mb-3'}, [
    label {class: 'form-label', for: id}, text props.label
    input inputOpts
    if props.encrypted then small {class: 'form-text'}, text '''
      この項目は暗号化されて保存されます。
    '''
    if props.description then small {id: describeId, class: 'form-text'}, text props.description
  ]

inputCheckbox = (props) ->
  name = fieldName(props.name, parentNames)
  id = fieldId(props.name, parentNames)
  describeId = "#{id}-help"

  hiddenInputOpts = {
    name: name
    type: 'hidden'
    value: '0'
  }

  inputOpts = {
    id: id
    name: name
    type: 'checkbox'
    class: 'form-check-input'
    value: '1'
    'aria-edscribedby': describeId
  }

  if props.value
    inputOpts['checked'] = true

  div {class: 'form-check'}, [
    input hiddenInputOpts
    input inputOpts
    label {class: 'form-check-label', for: id}, text props.label
    if props.description? then small {id: describeId, class: 'form-text'}, text props.description
  ]

inputTextarea = (props) ->
  name = fieldName(props.name, parentNames)
  id = fieldId(props.name, parentNames)
  describeId = "#{id}-help"

  inputOpts = {
    id: id
    name: name
    class: 'form-control'
    value: props.value ? (if props.encrypted? then props.default else '')
    'aria-edscribedby': describeId
  }

  for key in [
    'required', 'placeholder', 'maxlength', 'minlength', 'cols', 'rows'
  ]
    inputOpts[key] = props[key] if props[key]?

  div {class: 'mb-3'}, [
    label {class: 'form-label', for: id}, text props.label
    textarea inputOpts
    if props.encrypted? then small {class: 'form-text'}, text '''
      この項目は暗号化されて保存され、現在の値は表示されません。
      変更しない場合は、空欄のままにしてください。
    '''
    if props.description? then small {id: describeId, class: 'form-text'}, text props.description
  ]

inputList = (props) ->
  name = fieldName(props.name, parentNames)
  id = fieldId(props.name, parentNames)
  describeId = "#{id}-help"

  selected = props.value ? props.default

  div {class: 'mb-3'}, [
    label {class: 'form-label', for: id}, text props.label
    select {
      id: id
      class: 'form-control'
      name: name
      'aria-describedby': describeId
    },
      for item in props.list
        option {value: item.value, selected: selected == item.value}, text item.name
    if props.description? then small {id: describeId, class: 'form-text'}, text props.description
  ]

inputParam = (props) ->
  if props.list?
    return inputList props

  inputType = props.input ? switch props.type
    when 'boolean' then 'checkbox'
    when 'string' then 'text'
    when 'text' then 'textarea'
    when 'integer' then 'number'
    when 'float' then 'number'
    when 'date' then 'date'
    when 'time' then 'time'
    when 'datetime' then 'datetime-local'
    when 'file' then 'file'

  switch inputType
    when 'text', 'password', 'email', 'searh', 'tel', 'url', \
          'number', 'range', 'color', \
          'date', 'time', 'datetime-local', 'month', 'week'
      inputControl {props..., inputType}
    when 'checkbox'
      inputCheckbox {props..., inputType}
    when 'textarea'
      inputTextarea {props..., inputType}
    else
      text '未実装の形式です。'


export default providerParams = ({params, param_types, props...}) ->
  div {}, [
    h5 {},
      text 'パラメーター'
    div {},
      if param_types.length > 0
        for param_type in param_types
          inputParam {props..., param_type..., value: params[param_type.name]}
      else
        text "設定できるパラメーターはありません。"
  ]
