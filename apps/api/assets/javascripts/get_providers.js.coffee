# /api/providers

import {createRunGet} from './run_json.js'

export API_PROVIDERS = '/api/providers'

export SetProviders = (state, providers) -> {state..., providers}

export createRunGetProviders = (action = SetProviders) -> createRunGet(action, API_PROVIDERS)

export runGetProviders = createRunGetProviders()

export GetProviders = (state) -> [state, runGetProviders]
