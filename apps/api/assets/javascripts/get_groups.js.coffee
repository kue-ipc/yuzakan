# /api/groups

import {fetchJsonGet} from './fetch_json.js'

MAX_PER_PAGE = 100
MAX_PAGE = 10000

export SetGroups = (state, groups) -> {state..., groups}

export runGetGroups = (dispatch, action = SetGroups) ->
  groups = []

  for page in [1..MAX_PAGE]
    response = await fetchJsonGet({url: '/api/groups', data: {page, per_page: MAX_PER_PAGE, no_sync: true}})
    if response.ok
      groups = [groups..., response.data...]
      break if groups.length >= response.total
    else
      console.error response
      return

  dispatch(SetAllGroups, groups)
