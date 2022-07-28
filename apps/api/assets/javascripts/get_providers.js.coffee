# /api/system

import {fetchJsonGet} from './fetch_json.js'

export SetProviders = (state, providers) -> {state..., providers}

export runGetSystem = (dispatch, action = SetProviders) ->
  response = await fetchJsonGet({url: '/api/providers'})
  if response.ok
    dispatch(action, response.data)
  else
    console.error response
