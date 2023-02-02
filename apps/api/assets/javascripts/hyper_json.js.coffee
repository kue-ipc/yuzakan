# Createer functions for Hyperapp object and fetch api

import _ from '/assets/vendor/lodash.js'

import {fetchJson, MIN_PAGE, MAX_PAGE, MIN_PER_PAGE, MAX_PER_PAGE} from './fetch_json.js'

# create Actions

# データを受け取るアクションからレスポンスに対応した新しいアクションを作成する
export createResponseAction = (action, ng = null) ->
  (_state, response) ->
    if response.ok
      [action, response.data]
    else if response.code == 404
      [action, response.data]


# データを受け取るアクションからページ情報付きのレスポンスに対応した新しいアクションを作成する
export createResponseActionPage = (action) ->
  (state, response) ->
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

# create Effecter

# レスポンスを直接渡すアクションを作成する。
export createRunResponse = ({action, method, url, allowKeys = []}) ->
  (dispatch, props = {}) ->
    data = _.pick(props, allowKeys)
    response = await fetchJson({url, method, data})
    dispatch(action, response)


export createRunGetResponse = (action, url, allowKeys = []) ->
  (dispatch, props = {}) ->
    data = _.pick(props, allowKeys)
    response = await fetchJsonGet({url, data})
    if response.ok
      dispatch(action, response)
    else
      console.error response




export createRunGetResponse = (action, url, allowKeys = []) ->
  (dispatch, props = {}) ->
    data = _.pick(props, allowKeys)
    response = await fetchJsonGet({url, data})
    if response.ok
      dispatch(action, response)
    else
      console.error response

# レスポンスを直接渡すアクションを作成する。
export createRunGetResponse = (action, url, allowKeys = []) ->
  (dispatch, props = {}) ->
    data = _.pick(props, allowKeys)
    response = await fetchJsonGet({url, data})
    if response.ok
      dispatch(action, response)
    else
      console.error response

export createRunGet = (action, url, allowKeys = []) ->
  responseAction = createResponseAction(action)
  createRunGetResponse(responseAction, url, allowKeys)

export createRunGetPage = (action, url, allowKeys = []) ->
  responseAction = createResponseActionPage(action)
  createRunGetResponse(responseAction, url, [allowKeys..., 'page', 'per_page'])

export createRunName = (action, url, allowKeys = []) ->
  responseAction = createResponseAction(action)
  createRunGetResponse(responseAction, url, allowKeys)

export createRunGetWithPagination = (action, url, allowKeys = []) ->
  (dispatch, props = {}) ->
    data = _.pick(props, allowKeys)
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
