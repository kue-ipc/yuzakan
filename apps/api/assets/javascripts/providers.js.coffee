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

# create Effecters

export createRunIndexProviders = ({action = SetProviders, params...} = {}) ->
  createRunIndex({
    action
    url: API_PROVIDERS
    dataTypes: INDEX_PROVIDERS_PARAM_TYPES
    params...
  })

export createRunShowProvider = ({action = SetProvider, params...} = {}) ->
  createRunShowWithId({
    action
    url: API_PROVIDERS
    dataTypes: SHOW_PROVIDER_PARAM_TYPES
    params...
  })

export createRunCreateProvider = ({action = SetProvider, params...} = {}) ->
  createRunCreateWithId({
    action
    url: API_PROVIDERS
    dataTypes: CREATE_PROVIDER_PARAM_TYPES
    params...
  })

export createRunUpdateProvider = ({action = SetProvider, params...} = {}) ->
  createRunUpdateWithId({
    action
    url: API_PROVIDERS
    dataTypes: UPDATE_PROVIDER_PARAM_TYPES
    params...
  })

export createRunDestroyProvider = ({action = SetProvider, params...} = {}) ->
  createRunDestroyWithId({
    action
    url: API_PROVIDERS
    dataTypes: DESTROY_PROVIDER_PARAM_TYPES
    params...
  })
