# /api/users

import {createRunPage, createRunGetWithPagination} from './run_json.js'

export API_USERS = '/api/users'

# Actions

export SetUsers = (state, users) -> {state..., users}

export GetUsers = (state) -> [state, runGetUsers]

export PageUsers = (state) -> [state, [runPageUsers, state]]

# Effecter Generators

export createRunGetUsers = (action = SetUsers) -> createRunGetWithPagination(action, API_USERS)

export createRunPageUsers = (action = SetUsers) -> createRunPage(action, API_USERS, ['query'])

# Effecters

export runGetUsers = createRunGetUsers()

export runPageUsers = createRunPageUsers()
