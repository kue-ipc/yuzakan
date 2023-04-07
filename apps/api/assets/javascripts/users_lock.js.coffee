# /api/users/:user_id/lock

import {
  createRunCreate
  createRunDestroy
} from '/assets/api/hyper_json.js'

import {SetUser, normalizeUser} from '/assets/api/users.js'

# Contants

export USER_ID_KEY_USERS_LOCK = 'user_id'
export API_USERS_LOCK = "/api/users/:#{USER_ID_KEY_USERS_LOCK}/lock"

# Functions

# Actions

# create Effecters

export createRunCreateUserLock = (params = {}) ->
  createRunCreate({
    action: SetUser
    normalizer: normalizeUser
    url: API_USERS_LOCK
    pathKeys: [USER_ID_KEY_USERS_LOCK]
    params...
  })

export createRunDestroyUserLock = (params = {}) ->
  createRunDestroy({
    action: SetUser
    normalizer: normalizeUser
    url: API_USERS_LOCK
    pathKeys: [USER_ID_KEY_USERS_LOCK]
    params...
  })

# Effecters

export runCreateUserLock = createRunCreateUserLock()
export runDestroyUserLock = createRunDestroyUserLock()
