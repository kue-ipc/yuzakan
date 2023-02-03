# /api/providers

import {
  createRunIndex
  createRunShowWithId
  createRunCreateWithId
  createRunUpdateWithId
  createRunDestroyWithId
} from './hyper_json.js'

export API_PROVIDERS = '/api/providers'

# Actiosn

export SetProviders = (state, providers) -> {state..., providers}

export SetProvider = (state, provider) -> {state..., provider}

# create Actions

export createSetProviders = (action = null) ->
  if action?
    (state, providers) ->
      action(SetProviders(state, providers), providers)
  else
    SetProviders

export createSetProvider = (action = null) ->
  if action?
    (state, provider) ->
      action(SetProvider(state, provider), provider)
  else
    SetProvider

# create Effecters

export createRunIndexProviders = ({action = null, params...} = {}) ->
  createRunIndex({params..., action: createSetProviders(action), url: API_PROVIDERS, dataKeys: ['filter']})

export createRunShowProvider = ({action = null, params...} = {}) ->
  createRunShowWithId({params..., action: createSetProvider(action), url: API_PROVIDERS, idKey: 'name'})

# Effecters

export runIndexProviders = createRunIndexProviders()

export runShowProvider = createRunShowProvider()
