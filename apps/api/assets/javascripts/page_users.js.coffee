# /api/system

import {fetchJsonGet} from './fetch_json.js'

export SetUsers = (state, {users, pager}) -> {state..., users, pager}

export runGetUsers = (dispatch, {action = SetSetUsers, pager = {}, query} = {}) ->
  data = {pager..., query}

  response = await fetchJsonGet({url: '/api/providers'})
  if response.ok
    dispatch(action, {
      users: response.data
      pager: 
    })
  else
    console.error response

export GetUsers = (state) -> [state, runGetUsers]
