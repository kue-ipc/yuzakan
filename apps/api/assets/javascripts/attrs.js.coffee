# /api/attrs

import {
  createRunIndex
  createRunShowWithId
  createRunCreateWithId
  createRunUpdateWithId
  createRunDestroyWithId
} from './hyper_json.js'

import {pickType} from '/assets/common/utils.js'

# Constants

export API_ATTRS = '/api/attrs'

export ATTR_PROPERTIES = {
  name: 'string'
  display_name: 'string'
  type: 'string'
  order: 'integer'
  hidden: 'boolean'
  readonly: 'boolean'
  code: 'string'
  description: 'string'
}

export INDEX_ATTRS_PARAM_TYPES = {
}

export SHOW_ATTR_PARAM_TYPES = {
}

export CREATE_ATTR_PARAM_TYPES = {
  ATTR_PROPERTIES...
}

export UPDATE_ATTR_PARAM_TYPES = {
  ATTR_PROPERTIES...
}

export DESTROY_ATTR_PARAM_TYPES = {
}

# Functions

export normalizeAttrs = (attrs, type ={}) ->
  normalizeAttr(attr, type) for attr in attrs

export normalizeAttr = (attr, types = {}) ->
  pickType(attr, {
    ATTR_PROPERTIES...
    mappings: 'list'
    types...
  })

# Actiosn

export SetAttrs = (state, attrs) -> {
  state...
  attrs
}

export SetAttr = (state, attr) -> {
  state...
  attr
}

# create Effecters

export createRunIndexAttrs = (params = {}) ->
  createRunIndex({
    action: SetAttrs
    normalizer: normalizeAttrs
    url: API_ATTRS
    dataTypes: INDEX_ATTRS_PARAM_TYPES
    params...
  })

export createRunShowAttr = (params = {}) ->
  createRunShowWithId({
    action: SetAttr
    normalizer: normalizeAttr
    url: API_ATTRS
    dataTypes: SHOW_ATTR_PARAM_TYPES
    params...
  })

export createRunCreateAttr = (params = {}) ->
  createRunCreateWithId({
    action: SetAttr
    normalizer: normalizeAttr
    url: API_ATTRS
    dataTypes: CREATE_ATTR_PARAM_TYPES
    params...
  })

export createRunUpdateAttr = (params = {}) ->
  createRunUpdateWithId({
    action: SetAttr
    normalizer: normalizeAttr
    url: API_ATTRS
    dataTypes: UPDATE_ATTR_PARAM_TYPES
    params...
  })

export createRunDestroyAttr = (params = {}) ->
  createRunDestroyWithId({
    action: SetAttr
    normalizer: normalizeAttr
    url: API_ATTRS
    dataTypes: DESTROY_ATTR_PARAM_TYPES
    params...
  })
