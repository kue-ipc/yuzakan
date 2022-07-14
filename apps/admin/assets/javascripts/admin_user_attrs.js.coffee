import {toRomaji, toKatakana, toHiragana} from '../ja_conv.js'
import {capitalize} from '../string_utils.js'
import {xxh32, xxh64} from '../hash.js'

export getAttrDefaultValue = ({username, attrs, code}) ->
  return unless code

  code =
    if /\breturn\b/.test(code)
      code
    else
      "return #{code};"

  func = new Function('{username, attrs, tools}', code)
  try
    result = func {
      username
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
  if attrs.length == 0
    return {state..., user, attrs}

  checked = user.attrs?
  if checked
    userAttrs = user.attrs
    attrValues = {}
    for own name, value of userAttrs
      attrValues[name] = value.value
  else
    userAttrs = {}
    for own name, value of user.userdata.attrs
      userAttrs[name] = {value, setting: 'input'}
    user = {user..., attrs: userAttrs}
    attrValues = user.userdata.attrs

  for attr in attrs when attr.code
    defaultValue = getAttrDefaultValue({username: user.name, attrs: attrValues, code: attr.code})
    newAttr =
      if checked
        if userAttrs[attr.name].setting == 'default'
          {userAttrs[attr.name]..., value: defaultValue, default: defaultValue}
        else
          {userAttrs[attr.name]..., default: defaultValue}
      else if state.mode == 'new'
        {userAttrs[attr.name]..., value: defaultValue, default: defaultValue, setting: 'default'}
      else if defaultValue == userAttrs[attr.name]?.value || !userAttrs[attr.name]?
        {userAttrs[attr.name]..., default: defaultValue, setting: 'default'}
      else
        {userAttrs[attr.name]..., default: defaultValue, setting: 'custom'}
    userAttrs = {userAttrs..., [attr.name]: newAttr}

  {state..., user: {user..., attrs: userAttrs}, attrs: attrs}
