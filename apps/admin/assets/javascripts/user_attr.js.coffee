import {text} from '~/vendor/hyperapp.js'
import * as html from '~/vendor/hyperapp-html.js'

import {entityLabel} from '~/common/helper.js'

import valueDisplay from '~/app/value_display.js'

import {CalcUserAttrs} from '~/admin/user_attrs.js'

SetUserAttr = (state, {attr_name, value}) ->
  user = {state.user..., attrs: {state.user.attrs..., [attr_name]: value}}
  [CalcUserAttrs, {user}]

attrValue = ({attr_name, value, type = 'string', edit = false, color = 'body'}) ->
  if edit
    switch type
      when 'string'
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'text'
          value
          oninput: (state, event) -> [SetUserAttr, {attr_name, value: event.target.value}]
        }
      when 'boolean'
        html.div {class: 'form-check'},
          html.input {
            id: "value-#{name}"
            class: 'form-check-input'
            type: 'checkbox'
            checked: value
            onchange: (state, event) -> [SetUserAttr, {attr_name, value: event.target.checked}]
          }
      when 'integer'
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'number'
          value
          oninput: (state, event) -> [SetUserAttr, {attr_name, value: parseInt(event.target.value)}]
        }
      when 'float'
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'number'
          value
          step: '0.001'
          oninput: (state, event) -> [SetUserAttr, {attr_name, value: Number(event.target.value)}]
        }
      when 'datetime'
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'datetime-local'
          value
          oninput: (state, event) -> [SetUserAttr, {attr_name, value: event.target.value}]
        }
      when 'date'
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'date'
          value
          oninput: (state, event) -> [SetUserAttr, {attr_name, value: event.target.value}]
        }
      when 'time'
        html.input {
          id: "value-#{name}"
          class: 'form-control'
          teype: 'time'
          value
          oninput: (state, event) -> [SetUserAttr, {attr_name, value: event.target.value}]
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


attrSetting = ({attr_name, checked, edit}) ->
  if edit
    html.div {class: 'form-check'},
      html.input {
        id: "value-#{name}"
        class: 'form-check-input'
        type: 'checkbox'
        checked: checked
        onchange: [ChangeAttrSetting, {attr_name, setting: if checked then 'custom' else 'default'}]
      }
  else
    valueDisplay({value: checked, type: 'boolean'})

attrSettingTd = ({mode, user, attr}) ->
  html.td {},
    switch user.attrSettings?[attr.name]
      when 'default'
        attrSetting {attr_name: attr.name, checked: true, edit: mode != 'show'}
      when 'custom'
        attrSetting {attr_name: attr.name, checked: false, edit: mode != 'show'}
      else
        []

attrDefaultTd = ({user, attr}) ->
  html.td {},
    # valueDisplay {value: user.attrDefaults[attr.name], type: attr.type}
    valueDisplay {value: undefined, type: attr.type}

attrValueTd = ({mode, user, attr}) ->
  # defaultValue = user.attrDefaults[attr.name]
  defaultValue = null #TODO
  value = user.attrs.get(attr.name)
  html.td {},
    attrValue {
      attr_name: attr.name
      value: value
      type: attr.type
      edit: mode != 'show' && user.attrSettings[attr.name] != 'default' && !attr.readonly
      color:
        if !defaultValue?
          'body'
        else if defaultValue == value
          'success'
        else
          'danger'
    }

providerTd = ({user, attr, provider}) ->
  return html.td {} unless user.providers.includes(provider.name)

  data = user.providers_data.get(provider.name)
  # provider_userdata = (user.provider_userdatas.find (data) -> data.provider.name == provider.name)
  return html.td {} unless data?

  provider_value = data.attrs.get(attr.name)

  html.td {},
    valueDisplay {
      value: provider_value
      type: attr.type
      color: if provider_value == user.attrs.get(attr.name) then 'success' else 'danger'
    }

export default userAttr = ({mode, user, providers, attrs}) ->
  # provider_userdatas =
  # for provider in providers
  #   (user.provider_userdatas.find (data) -> data.provider.name == provider.name)?.userdata

  html.div {}, [
    html.h4 {}, text '属性一覧'

    html.table {class: 'table'}, [
      html.thead {},
        html.tr {}, [
          html.th {}, text '属性名'
          # html.th {}, text 'デフォルト値'
          # html.th {}, text 'デファルト'
          html.th {}, text '設定値'
          (html.th({}, text entityLabel(provider)) for provider in providers)...
        ]
      html.tbody {},
        for attr in attrs
          html.tr {}, [
            html.td {}, text entityLabel(attr)
            # attrDefaultTd {user, attr}
            # attrSettingTd {mode, user, attr}
            attrValueTd {mode, user, attr}
            (providerTd {user, attr, provider} for provider in providers)...
          ]
    ]
  ]
