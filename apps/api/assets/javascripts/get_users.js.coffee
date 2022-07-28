# /api/users

import {createRunPage, createRunGetWithPagination} from './run_json.js'

export API_USERS = '/api/users'

export SetUsers = (state, users) -> {state..., users}

export createRunGetUsers = (action = SetUsers) -> createRunGetWithPagination(action, API_USERS)

export runGetUsers = createRunGetUsers()

export GetUsers = (state) -> [state, [runGetUsers, state]]

export createRunPageUsers = (action = SetUsers) -> createRunPage(action, API_USERS, ['query'])

export runPageUsers = createRunPageUsers()

export PageUsers = (state) -> [state, [runPageUsers, state]]
