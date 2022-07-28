# /api/users

import {fetchJsonGet} from './fetch_json.js'

MAX_PER_PAGE = 100
MAX_PAGE = 10000

export SetUsers = (state, users) -> {state..., users}

export runGetUsers = (dispatch, action = SetUsers) ->
  users = []

  for page in [1..MAX_PAGE]
    response = await fetchJsonGet({url: '/api/users', data: {page, per_page: MAX_PER_PAGE, no_sync: true}})
    if response.ok
      users = [users..., response.data...]
      break if users.length >= response.total
    else
      console.error response
      return

  dispatch(SetAllGroups, users)
