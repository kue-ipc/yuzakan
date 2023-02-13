# /api/providers

import {
  createRunIndex
  createRunShowWithId
  createRunCreateWithId
  createRunUpdateWithId
  createRunDestroyWithId
} from './hyper_json.js'

export API_PROVIDERS = '/api/providers'

export PROVIDER_PROPERTIES = {
  name: 'string'
  display_name: 'string'
  adapter_name: 'string'
  order: 'integer'
  readable: 'boolean'
  writable: 'boolean'
  authenticatable: 'boolean'
  password_changeable: 'boolean'
  lockable: 'boolean'
  group: 'boolean'
  individual_password: 'boolean'
  self_management: 'boolean'
  description: 'string'
}

export INDEX_PROVIDERS_PARAM_TYPES = {
  has_groups: 'boolean'
}

export SHOW_PROVIDER_PARAM_TYPES = {
}

export CREATE_PROVIDER_PARAM_TYPES = {
  PROVIDER_PROPERTIES...
}

export UPDATE_PROVIDER_PARAM_TYPES = {
  PROVIDER_PROPERTIES...
}

export DESTROY_PROVIDER_PARAM_TYPES = {
}


# Actiosn

export SetProviders = (state, providers) -> {state..., providers}

export SetProvider = (state, provider) -> {state..., provider}

# create Actions

export createSetProviders = (action = null) ->
  if action?
    runAction = (dispatch, providers) -> dispatch(action, providers)
    (state, providers) ->
      [
        SetProviders(state, groups)...,
        [runAction, providers]
      ]
  else
    SetProviders

export createSetProvider = (action = null) ->
  if action?
    runAction = (dispatch, provider) -> dispatch(action, provider)
    (state, provider) ->
      [
        SetProvider(state, provider)...,
        [runAction, provider]
      ]
  else
    SetProvider

# create Effecters

export createRunIndexProviders = ({action = null, params...} = {}) ->
  createRunIndex({
    action: createSetProviders(action)
    url: API_PROVIDERS
    dataTypes: INDEX_PROVIDERS_PARAM_TYPES
    params...
  })

export createRunShowProvider = ({action = null, params...} = {}) ->
  createRunShowWithId({
    action: createSetProvider(action)
    url: API_PROVIDERS
    dataTypes: SHOW_PROVIDER_PARAM_TYPES
    params...
  })

# Effecters

export runIndexProviders = createRunIndexProviders()

export runShowProvider = createRunShowProvider()
