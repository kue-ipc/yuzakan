# /api/users

import {
  createRunIndex
  createRunIndexWithPage
  createRunShowWithId
  createRunCreateWithId
  createRunUpdateWithId
  createRunDestroyWithId
} from './hyper_json.js'

import {PAGINATION_PARAM_TYPES} from './pagination.js'

import {pickType} from '/assets/utils.js'

# Contants

export API_USERS = '/api/users'

export USER_PROPERTIES = {
  # name: 'string'
  # display_name: 'string'
  # note: 'string'
  # primary: 'boolean'
  # prohibited: 'boolean'
  # deleted: 'boolean'
  # deleted_at: 'datetime'
}

export INDEX_USERS_PARAM_TYPES = {
  sync: 'boolean'
  order: 'string'
  query: 'string'
  hide_prohibited: 'boolean'
  show_deleted: 'boolean'
}

export INDEX_WITH_PAGE_USERS_PARAM_TYPES = {
  PAGINATION_PARAM_TYPES...
  INDEX_USERS_PARAM_TYPES...
}

export SHOW_USER_PARAM_TYPES = {
  sync: 'boolean'
}

export CREATE_USER_PARAM_TYPES = {
  USER_PROPERTIES...
}

export UPDATE_USER_PARAM_TYPES = {
  USER_PROPERTIES...
}

export DESTROY_USER_PARAM_TYPES = {
  permanent: 'boolean'
}

# Functions

export normalizeUsers = (users, type ={}) ->
  normalizeUser(user, type) for user in users

export normalizeUser = (user, types = {}) ->
  pickType(user, {
    USER_PROPERTIES...
    data: 'map'
    providers: 'map'
    types...
  })

# Actions

export SetUsers = (state, users) -> {
  state...
  users
}

export SetUser = (state, user) -> {
  state...
  user
}

# create Effecters

export createRunIndexUsers = (params = {}) ->
  createRunIndex({
    action: SetUsers
    normalizer: normalizeUsers
    url: API_USERS
    dataTypes: INDEX_USERS_PARAM_TYPES
    params...
  })

export createRunIndexWithPageUsers = (params = {}) ->
  createRunIndexWithPage({
    action: SetUsers
    normalizer: normalizeUsers
    url: API_USERS
    dataTypes: INDEX_WITH_PAGE_USERS_PARAM_TYPES
    params...
  })

export createRunShowUser = (params = {}) ->
  createRunShowWithId({
    action: SetUser
    normalizer: normalizeUser
    url: API_USERS
    dataTypes: SHOW_USER_PARAM_TYPES
    params...
  })

export createRunCreateUser = (params = {}) ->
  createRunCreateWithId({
    action: SetUser
    normalizer: normalizeUser
    url: API_USERS
    dataTypes: CREATE_USER_PARAM_TYPES
    params...
  })

export createRunUpdateUser = (params = {}) ->
  createRunUpdateWithId({
    action: SetUser
    normalizer: normalizeUser
    url: API_USERS
    dataTypes: UPDATE_USER_PARAM_TYPES
    params...
  })

export createRunDestroyUser = (params = {}) ->
  createRunDestroyWithId({
    action: SetUser
    normalizer: normalizeUser
    url: API_USERS
    dataTypes: DESTROY_USER_PARAM_TYPES
    params...
  })




# import {createRunPage, createRunGetWithPagination} from './run_json.js'

# export API_USERS = '/api/users'

# # Actions

# export SetUsers = (state, users) -> {state..., users}

# export GetUsers = (state) -> [state, runGetUsers]

# export PageUsers = (state) -> [state, [runPageUsers, state]]

# # Effecter Generators

# export createRunGetUsers = (action = SetUsers) -> createRunGetWithPagination(action, API_USERS)

# export createRunPageUsers = (action = SetUsers) -> createRunPage(action, API_USERS, ['query'])

# # Effecters

# export runGetUsers = createRunGetUsers()

# export runPageUsers = createRunPageUsers()
