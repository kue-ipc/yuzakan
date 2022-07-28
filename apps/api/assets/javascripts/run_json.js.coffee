# /api/attrs

import {fetchJsonGet, MIN_PAGE, MAX_PAGE, MAX_PER_PAGE} from './fetch_json.js'

export createJsonGetAction = (action) -> (_state, response) -> [action, response.data]

export createJsonPageAction = (action) -> (state, response) ->
  effecter = (dispatch, props) -> dispatch(action, props)
  [
    {
      state...
      total: response.total
      start: response.start
      end: response.end
      page: response.page
      per_page: response.per_page
    }
    [effecter, response.data]
  ]

dataFilter = (obj, keys) ->
  return if keys.length == 0

  data = {}
  for key in keys
    data[key] = obj[key] if obj[key]?
  return if Object.keys(data).length == 0

  data

export createRunJson = (action, url, allowKeys = []) ->
  (dispatch, props = {}) ->
    data = dataFilter(props, allowKeys)
    response = await fetchJsonGet({url, data})
    if response.ok
      dispatch(action, response)
    else
      console.error response

export createRunGet = (action, url, allowKeys = []) ->
  responseAction = createJsonGetAction(action)
  createRunJson(responseAction, url, allowKeys)

export createRunPage = (action, url, allowKeys = []) ->
  responseAction = createJsonPageAction(action)
  createRunJson(responseAction, url, [allowKeys..., 'page', 'per_page'])

export createRunGetWithPagination = (action, url, allowKeys = []) ->
  (dispatch, data) ->
    data = dataFilter(props, allowKeys)
    items = []
    for page in [MIN_PAGE..MAX_PAGE]
      response = await fetchJsonGet({url, data: {data..., page, per_page: MAX_PER_PAGE, no_sync: true}})
      if response.ok
        items = [items..., response.data...]
        break if items.length >= response.total
      else
        console.error response
        return
    dispatch(action, items)
