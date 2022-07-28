# /api/groups

import {createRunPage, createRunGetWithPagination} from './run_json.js'

export API_GROUPS = '/api/groups'

export SetGroups = (state, groups) -> {state..., groups}

export createRunGetGroups = (action = SetGroups) -> createRunGetWithPagination(action, API_GROUPS)

export runGetGroups = createRunGetGroups()

export GetGroups = (state) -> [state, [runGetGroups, state]]

export createRunPageGroups = (action = SetGroups) -> createRunPage(action, API_GROUPS, ['query'])

export runPageGroups = createRunPageGroups()

export PageGroups = (state) -> [state, [runPageGroups, state]]
