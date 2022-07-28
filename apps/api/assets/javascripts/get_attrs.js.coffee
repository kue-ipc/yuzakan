# /api/attrs

import {createResponseDataAction, createRunGet} from './run_get.js'

export SetAttrs = (state, attrs) -> {state..., attrs}

export createRunGetAttrs = (action = SetAttrs) ->
  responseAction = createResponseDataAction(action)
  createRunGet(createResponseDataAction(action), 'api/attrs')

export runGetAttrs = createRunGetAttrs()
