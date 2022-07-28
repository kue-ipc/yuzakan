# /api/attrs

import {fetchJsonGet} from './fetch_json.js'

export SetAttrs = (state, attrs) -> {state..., attrs}

export runGetSystem = (dispatch, action = SetAttrs) ->
  response = await fetchJsonGet({url: '/api/attrs'})
  if response.ok
    dispatch(action, response.data)
  else
    console.error response
