import {toRomaji, toKatakana, toHiragana} from '/assets/ja_conv.js'
import {capitalize} from '/assets/string_utils.js'
import {xxh32, xxh64} from '/assets/hash.js'

export getAttrDefaultValue = ({user, attrs, code}) ->
  return unless code

  code =
    if /\breturn\b/.test(code)
      code
    else
      "return #{code};"

  func = new Function('{name, display_name, email, primary_group, attrs, tools}', code)
  try
    result = func {
      name: user.name
      display_name: user.display_name
      email: user.email
      primary_group: user.primary_group
      attrs
      tools: {toRomaji, toKatakana, toHiragana, capitalize, xxh32, xxh64}
    }
  catch error
    console.warn({msg: 'Failed to getAttrDefaultValue', code: code, error: error})
    return

  result

export CalcUserAttrs = (state, {user, attrs}) ->
  user ?= state.user
  attrs ?= state.attrs

  attrValues = {user.attrs...}
  attrDefaults = {}

  for attr in attrs when attr.code
    attrDefaults[attr.name] = getAttrDefaultValue({user, attrs: attrValues, code: attr.code})
    if user.attrSettings[attr.name] == 'default'
      attrValues[attr.name] = attrDefaults[attr.name]

  {state..., user: {user..., attrs: attrValues, attrDefaults}, attrs}

export InitUserAttrs = (state, {user, attrs}) ->
  user ?= state.user
  attrs ?= state.attrs
  return {state..., user, attrs} unless user? && attrs?

  attrValues = {}
  attrDefaults = {}
  attrSettings = {}

  for attr in attrs
    unless attr.code
      attrValues[attr.name] = user.userdata.attrs[attr.name]
      attrSettings[attr.name] = 'input'
      continue

    attrDefaults[attr.name] = getAttrDefaultValue({user, attrs: user.userdata.attrs, code: attr.code})

    if state.mode == 'new' ||
        !user.userdata.attrs[attr.name]? ||
        user.userdata.attrs[attr.name] == attrDefaults[attr.name]
      attrSettings[attr.name] = 'default'
      attrValues[attr.name] = attrDefaults[attr.name]
    else
      attrSettings[attr.name] = 'custom'
      attrValues[attr.name] = user.userdata.attrs[attr.name]

  {state..., user: {user..., attrs: attrValues, attrSettings, attrDefaults}, attrs}
