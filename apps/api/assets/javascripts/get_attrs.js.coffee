# /api/attrs

import {fetchJsonGet} from './fetch_json.js'

export SetAttrs = (state, attrs) -> {state..., attrs}

export createRunGetSystem = (action = SetAttrs) ->
  (dispatch) ->
    response = await fetchJsonGet({url: '/api/attrs'})
    if response.ok
      dispatch(action, response.data)
    else
      console.error response

export runGetSystem = createRunGetSystem()
