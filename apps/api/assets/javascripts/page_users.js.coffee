# /api/users with page and query

import {fetchJsonGet} from './fetch_json.js'

export SetPageUsers = (state, {users, total, start, end, page, per_page}) ->
  {state..., users, total, start, end, page, per_page}

export runPageUsers = (dispatch, {page, per_page, query}) ->
  data = {page, per_page, query}
  response = await fetchJsonGet({url: '/api/providers', data})
  if response.ok
    dispatch(SetPageUsers, {
      users: response.data
      total: response.total
      start: response.start
      end: response.end
      page: response.page
      per_page: response.per_page
    })
  else
    console.error response
