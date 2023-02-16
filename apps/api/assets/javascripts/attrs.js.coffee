# /api/attrs

import {
  createRunIndex
  createRunShowWithId
  createRunCreateWithId
  createRunUpdateWithId
  createRunDestroyWithId
} from './hyper_json.js'

import {pickType} from '/assets/utils.js'

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
  mappings: 'list'
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

export normalizeAttr = (attr, types = {}) ->
  pickType(attr, {
    ATTR_PROPERTIES...
    types...
  })

# Actiosn

export SetAttrs = (state, attrs) -> {
  state...
  attrs: (normalizeAttr(attr) for attr in attrs)
}

export SetAttr = (state, attr) -> {
  state...
  attr: normalizeAttr(attr)
}

# create Effecters

export createRunIndexAttrs = ({action = SetAttrs, params...} = {}) ->
  createRunIndex({
    action
    url: API_ATTRS
    dataTypes: INDEX_ATTRS_PARAM_TYPES
    params...
  })

export createRunShowAttr = ({action = SetAttr, params...} = {}) ->
  createRunShowWithId({
    action
    url: API_ATTRS
    dataTypes: SHOW_ATTR_PARAM_TYPES
    params...
  })

export createRunCreateAttr = ({action = SetAttr, params...} = {}) ->
  createRunCreateWithId({
    action
    url: API_ATTRS
    dataTypes: CREATE_ATTR_PARAM_TYPES
    params...
  })

export createRunUpdateAttr = ({action = SetAttr, params...} = {}) ->
  createRunUpdateWithId({
    action
    url: API_ATTRS
    dataTypes: UPDATE_ATTR_PARAM_TYPES
    params...
  })

export createRunDestroyAttr = ({action = SetAttr, params...} = {}) ->
  createRunDestroyWithId({
    action
    url: API_ATTRS
    dataTypes: DESTROY_ATTR_PARAM_TYPES
    params...
  })


# import {createRunGet} from './run_json.js'

# export API_ATTRS = '/api/attrs'

# export SetAttrs = (state, attrs) -> {state..., attrs}

# export createRunGetAttrs = (action = SetAttrs) -> createRunGet(action, API_ATTRS)

# export runGetAttrs = createRunGetAttrs()

# export GetAttrs = (state) -> [state, runGetAttrs]
