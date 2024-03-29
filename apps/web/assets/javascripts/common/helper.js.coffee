# utils

import * as R from 'ramda'

import {convertToType} from '~/common/convert.js'

export isNil = R.isNil

export isEmpty = R.isEmpty

export isBlank = (obj) -> isNil(obj) || isEmpty(obj)

export isPresent = R.compose(R.not, isBlank)

export identity = R.identity

export presence = (obj) ->
  if isPresent(obj)
    obj
  else
    null

export uniq = R.uniq

export compact = (obj) ->
  switch R.type(obj)
    when 'Array'
      (v for v in obj when v?)
    when 'Object'
      Object.fromEntries([k, v] for own k, v of obj when v?)
    when 'Map'
      new Map([k, v] for [k, v] from obj when v?)
    when 'Set'
      new Set(v for v from obj when v?)
    else
      console.warn "cannot compact type: #{R.type(obj)}"
      obj

export pick = R.flip(R.pick)

export pickType = (obj, types) ->
  Object.fromEntries([key, convertToType(obj[key], type)] for own key, type of types when key of obj)

export basename = (path, suffix = '') ->
  return '' unless path

  base = path.split('/').reverse().find(identity) || '/'

  return base unless suffix

  lastDot = base.lastIndexOf('.')
  return base if lastDot <= 0

  if suffix == '.*' || suffix == base.slice(lastDot)
    base.slice(0, lastDot)
  else
    base

export entityLabel = (entity) ->
  return undefined unless entity?

  entity.display_name || entity.name || ''

# URLから最後の文字列を取り出す。
# 空文字列しかない場合は undefined を返す
export getBasenameFromUrl = (url) ->
  basename(url.pathname)

export getQueryParamsFromUrl = (url) ->
  Object.fromEntries(new URLSearchParams(url.search))

# TODO
# export deepFreeze = (obj)
#   return obj if Object.isFrozen(obj)

#   Object.freeze(obj)
#   switch Object.getPrototypeOf(obj).constructor
#     when Object
#       deepFreeze(value) for own key, value of obj
#     when Array
#       deepFreeze(value) for value in obj
#     when Map
#       deepFreeze(value) for value from obj.values()
#     when Set
#       deepFreeze(value) for value from obj
#   obj

# export clone

# export deepClone

