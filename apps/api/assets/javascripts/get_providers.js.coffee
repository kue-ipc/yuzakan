# /api/providers

import {createRunGet} from './run_json.js'

export API_USERS = '/api/providers'

export SetProviders = (state, providers) -> {state..., providers}

export createRunGetProviders = (action = SetProviders) -> createRunGet(action, API_USERS)

export runGetProviders = createRunGetProviders()
