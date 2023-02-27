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
import {SEARCH_PARAM_TYPES} from './search.js'
import {ORDER_PARAM_TYPES} from './order.js'

import {pickType} from '/assets/common/helper.js'

# Contants

export API_USERS = '/api/users'

export USER_PROPERTIES = {
  name: 'string'
  display_name: 'string'
  email: 'string'
  note: 'string'
  clearance_level: 'integer'
  prohibited: 'boolean'
  deleted: 'boolean'
  deleted_at: 'datetime'
  primary_group: 'string'
  groups: 'list'
  attrs: 'map'
}

export USER_DATA_PROPERTIES = {
  username: 'string'
  display_name: 'string'
  email: 'string'
  primary_group: 'string'
  groups: 'list'
  locked: 'boolean'
  unmanageable: 'boolean'
  mfa: 'boolean'
  attrs: 'map'
}

export INDEX_USERS_OPTION_PARAM_TYPES = {
  sync: 'boolean'
  hide_prohibited: 'boolean'
  show_deleted: 'boolean'
}

export INDEX_USERS_PARAM_TYPES = {
  SEARCH_PARAM_TYPES...
  ORDER_PARAM_TYPES...
  INDEX_USERS_OPTION_PARAM_TYPES...
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
  providersData =
    if !user.providers?
      {}
    else if user.providers instanceof Array
      {providers: user.providers}
    else
      {
        providers: (provider for provider, data of user.providers when data?)
        providers_data: new Map(
          [provider, pickType(data, GROUP_DATA_PROPERTIES)] for provider, data of user.providers when data?
        )
      }
  {
    pickType(user, {USER_PROPERTIES..., types...})...
    providersData...
  }

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
