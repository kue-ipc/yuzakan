# /api/users

import {createRunPage, createRunGetWithPagination} from './run_json.js'

export API_USERS = '/api/users'

export SetUsers = (state, users) -> {state..., users}

export createRunGetUsers = (action = SetUsers) -> createRunGetWithPagination(action, API_USERS)

export runGetUsers = createRunGetUsers()

export createRunPageUsers = (action = SetUsers) -> createRunPage(action, API_USERS)

export runPageUsers = createRunPageUsers()
