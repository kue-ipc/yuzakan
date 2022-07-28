# /api/attrs

import {createRunGet} from './run_json.js'

export API_ATTRS = '/api/attrs'

export SetAttrs = (state, attrs) -> {state..., attrs}

export createRunGetAttrs = (action = SetAttrs) -> createRunGet(action, API_ATTRS)

export runGetAttrs = createRunGetAttrs()

export GetAttrs = (state) -> [state, runGetAttrs]
