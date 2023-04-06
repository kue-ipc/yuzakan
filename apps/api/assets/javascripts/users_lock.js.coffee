# /api/users

# import {pickType} from '/assets/common/helper.js'

# import {PAGINATION_PARAM_TYPES} from '/assets/api/pagination.js'
# import {SEARCH_PARAM_TYPES} from '/assets/api/search.js'
# import {ORDER_PARAM_TYPES} from '/assets/api/order.js'
# import {
#   createRunIndex
#   createRunIndexWithPage
#   createRunShowWithId
#   createRunCreateWithId
#   createRunUpdateWithId
#   createRunDestroyWithId
# } from '/assets/api/hyper_json.js'



# Contants

export API_USERS_LOCK = '/api/users/:user_id/lock'

# Functions

# Actions

export SetUserLock = (state, ) -> {
  state...
  providers: 
}

# create Effecters

export createRunCreateUserLock = (params = {}) ->
  createRunCreateWithId({
    action: SetUser
    normalizer: normalizeUser
    url: API_USERS
    dataTypes: CREATE_USER_PARAM_TYPES
    params...
  })




# Effecters

export runIndexUsersNoSync = createRunIndexUsersNoSync()
export runIndexWithPageUsers = createRunIndexWithPageUsers()
export runShowUser = createRunShowUser()
export runCreateUser = createRunCreateUser()
export runUpdateUser = createRunUpdateUser()
export runDestroyUser = createRunDestroyUser()
