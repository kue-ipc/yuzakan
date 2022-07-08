import {text} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

import valueDisplay from '../value_display.js'

getAttrDefaultValue = ({userdata, attr}) ->
  return unless attr.code

  code =
    if /\breturn\b/.test(attr.code)
      attr.code
    else
      "return #{attr.code};"

  func = new Function('{name, username, display_name, email, attrs, tools}', code)
  try
    result = func {
      name: userdata.name
      username: userdata.name
      display_name: userdata.display_name
      email: userdata.email
      attrs: {userdata.attrs...}
      tools: {toRomaji, toKatakana, toHiragana, capitalize, xxh32, xxh64}
    }
  catch error
    console.warn({msg: 'Failed to getAttrDefaultValue', code: code, error: error})
    return

  result

attrValue = ({value, name = null, type = 'string', edit = false, color = 'body'}) ->
  if edit
    switch type
      when 'string'
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'text'
          value
          oninput: (state, event) -> [userValueAction, {name, value: event.target.value}]
        }
      when 'boolean'
        html.div {class: 'form-check'},
          html.input {
            id: "value-#{name}"
            class: 'form-check-input'
            type: 'checkbox'
            checked: value
            onchange: (state, event) -> [userValueAction, {name, value: !value}]
          }
      when 'integer'
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'number'
          value
          oninput: (state, event) -> [userValueAction, {name, value: parseInt(event.target.value)}]
        }
      when 'float'
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'number'
          value
          step: '0.001'
          oninput: (state, event) -> [userValueAction, {name, value: Number(event.target.value)}]
        }
      when 'datetime'
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'datetime'
          value
          oninput: (state, event) -> [userValueAction, {name, value: Date(event.target.value)}]
        }
      when 'date'
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'date'
          value
          oninput: (state, event) -> [userValueAction, {name, value: Date(event.target.value)}]
        }
      when 'time'
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'time'
          value
          oninput: (state, event) -> [userValueAction, {name, value: Date(event.target.value)}]
        }
      else
        throw new Error("not implemented: #{type}")
  else
    valueDisplay {value, type, color}

export default attrList = ({mode, user, providers, attrs, defaultAttrs}) ->
  html.div {}, [
    html.h4 {}, text '属性一覧'

    html.table {class: 'table'}, [
      html.thead {},
        html.tr {}, [
          html.th {}, text '属性名'
          html.th {}, text 'デフォルト値'
          html.th {}, text '設定値'
          (html.th({}, text provider.label) for provider in providers)...
        ]
      html.tbody {},
        for attr in attrs
          defaultValue = getAttrDefaultValue({userdata: user.userdata, attr})
          value = user.userdata.attrs[attr.name]

          html.tr {}, [
            html.td {}, text attr.label
            html.td {},
              attrValue {value: defaultValue, type: attr.type}

            html.td {},
              attrValue {
                name: "userdata.attrs.#{attr.name}"
                value: value
                type: attr.type
                edit: mode != 'show' && !attr.readonly
                color:
                  if not defaultValue?
                    'body'
                  else if defaultValue == value
                    'success'
                  else
                    'danger'
              }

            (
              for userdata in provider_userdatas
                html.td {},
                  attrValue {
                    value: userdata?.attrs?[attr.name]
                    type: attr.type
                    color:
                      if value == userdata?.attrs?[attr.name]
                        'success'
                      else
                        'danger'
                  }
            )...
          ]
    ]
  ]
