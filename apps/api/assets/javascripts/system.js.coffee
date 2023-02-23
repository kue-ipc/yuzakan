# /api/system

import {fetchJsonGet} from '/assets/api/fetch_json.js'

export SetSystem = (state, system) -> {state..., system}

export runGetSystem = (dispatch, action = SetSystem) ->
  response = await fetchJsonGet({url: '/api/system'})
  if response.ok
    dispatch(action, response.data)
  else
    console.error response
