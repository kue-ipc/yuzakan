import {text} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

import valueDisplay from '../value_display.js'
import {CalcUserAttrs} from './admin_user_attrs.js'

pointMerge = (obj, names, value) ->
  {
    obj...
    [names[0]]: if names.length == 1 then value else pointMerge(obj[names[0]], names.slice(1), value)
  }

userValueAction = (state, {name, value}) ->
  throw new Error('No name value aciton') unless name?
  pointMerge(state, ['user', name.split('.')...], value)

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

ChangeAttrSetting = (state, {attr_name, setting}) ->
  user = {
    state.user...
    attrSettings: {state.user.attrSettings..., [attr_name]: setting}
  }
  [CalcUserAttrs, {user}]

export default attrList = ({mode, user, providers, attrs}) ->
  provider_userdatas =
  for provider in providers
    (user.provider_userdatas.find (data) -> data.provider.name == provider.name)?.userdata

  html.div {}, [
    html.h4 {}, text '属性一覧'

    html.table {class: 'table'}, [
      html.thead {},
        html.tr {}, [
          html.th {}, text '属性名'
          html.th {}, text 'デフォルト値'
          html.th {}, text 'デファルト'
          html.th {}, text '設定値'
          (html.th({}, text provider.label) for provider in providers)...
        ]
      html.tbody {},
        for attr in attrs
          defaultValue = user.attrDefaults?[attr.name]
          value = user.attrs?[attr.name]

          html.tr {}, [
            html.td {}, text attr.label
            html.td {},
              attrValue {value: defaultValue, type: attr.type}

            html.td {},
              if mode == 'show'
                switch user.attrSettings?[attr.name]
                  when 'default'
                    valueDisplay({value: true, type: 'boolean'})
                  when 'custom'
                    valueDisplay({value: false, type: 'boolean'})
                  else
                    []
              else
                switch user.attrSettings?[attr.name]
                  when 'default'
                    html.div {class: 'form-check'},
                      html.input {
                        id: "value-#{name}"
                        class: 'form-check-input'
                        type: 'checkbox'
                        checked: true
                        onchange: [ChangeAttrSetting, {attr_name: attr.name, setting: 'custom'}]
                      }
                  when 'custom'
                    html.div {class: 'form-check'},
                      html.input {
                        id: "value-#{name}"
                        class: 'form-check-input'
                        type: 'checkbox'
                        checked: false
                        onchange: [ChangeAttrSetting, {attr_name: attr.name, setting: 'default'}]
                      }
                  else
                    []
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
