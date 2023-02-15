# Createer functions for Hyperapp object and fetch api

import {pick, pickType, identity} from '/assets/utils.js'
import csrf from '/assets/csrf.js'

import {fetchJson, DEFAULT_PAGE, DEFAULT_PER_PAGE} from './fetch_json.js'

# create Actions

# データを受け取るアクションからレスポンスに対応した新しいアクションを作成する。
# 404の場合はnull、それ以外はエラーでfallbackを実行する。
export createResponseAction = ({action, fallback = null}) ->
  (state, response) ->
    if response.ok
      [action, response.data]
    else if response.code == 404
      console.warn response
      [action, null]
    else
      console.error response
      if fallback
        [fallback, response.data]
      else
        # do nothing
        state

# データを受け取るアクションからページ情報付きのレスポンスに対応した新しいアクションを作成する。
# エラーの場合はページ情報を更新しない。
export createResponseActionSetPage = (params) ->
  responseAction = createResponseAction(params)
  runResponseAction = (dispatch, props) -> dispatch(responseAction, props)
  (state, response) ->
    if response.ok
      page_info = {
        pick(response, ['page', 'per_page', 'total', 'start', 'end'])...
        total_page: Math.ceil(response.total / response.per_page)
      }
      [
        {state..., page_info}
        [runResponseAction, response]
      ]
    else
      [responseAction, response]

# データを受け取るアクションでIDを更新するレスポンスに対応した新しいアクションを作成する。
# エラーの場合はIDを更新しない
export createResponseActionSetId = ({idKey = 'id', params...}) ->
  responseAction = createResponseAction(params)
  runResponseAction = (dispatch, props) -> dispatch(responseAction, props)
  (state, response) ->
    if response.ok
      url = new URL(response.location)
      last = url.pathname.split('/').reverse().find(identity)
      [
        {state..., [idKey]: last}
        [runResponseAction, response]
      ]
    else
      [responseAction, response]

# create Effecter

# レスポンスを直接渡すアクションを作成する。
# pathKeys内の文字列はそれぞれ部分文字列になっていはいけない。
export createRunResponse = ({action, url, pathKeys = [], dataTypes = [], method, data = {}, params...}) ->
  (dispatch, props = {}) ->
    for key in pathKeys
      unless key of props
        console.error 'given props does not have the property for path: %s', key
        return
      url = url.replace(":#{key}", props[key])
    data = {data..., pickType(props, dataTypes)...}
    if ['POST', 'PUT', 'PATCH', 'DELETE'].includes(method.toUpperCase())
      data = {data..., csrf()...}

    response = await fetchJson({method, url, data, params...})
    dispatch(action, response)

# RESTful Resources
# GET /resources
export createRunIndex = ({action, fallback = null, params...}) ->
  responseAction = createResponseAction({action, fallback})
  createRunResponse({action: responseAction, method: 'GET', params...})

# GET /resources?page=x&per_page=y
export createRunIndexWithPage = ({action, fallback = null, data = {}, params...}) ->
  responseAction = createResponseActionSetPage({action, fallback})
  data = {page: DEFAULT_PAGE, per_page: DEFAULT_PER_PAGE, data...}
  createRunResponse({action: responseAction, data, method: 'GET', params...})

# GET /resources/:id
export createRunShowWithId = ({action, fallback = null, url, idKey = 'id', params...}) ->
  responseAction = createResponseAction({action, fallback})
  url = "#{url}/:#{idKey}" unless url.includes(':#{idKey}')
  pathKeys = [idKey]
  createRunResponse({action: responseAction, url, pathKeys, method: 'GET', params...})

# POST /resources
export createRunCreateWithId = ({action, fallback = null, idKey = 'id', setId = false, params...}) ->
  responseAction = if setId
    createResponseActionSetId({action, fallback, idKey})
  else
    createResponseAction({action, fallback})
  createRunResponse({action: responseAction, method: 'POST', params...})

# PATCH /resources/:id
export createRunUpdateWithId = ({action, fallback = null, url, idKey = 'id', setId = false, params...}) ->
  responseAction = if setId
    createResponseActionSetId({action, fallback, idKey})
  else
    createResponseAction({action, fallback})
  url = "#{url}/:#{idKey}" unless url.includes(':#{idKey}')
  pathKeys = [idKey]
  createRunResponse({action: responseAction, url, pathKeys, method: 'PATCH', params...})

# DELETE /resources/:id
export createRunDestroyWithId = ({action, fallback = null, url, idKey = 'id', params...}) ->
  responseAction = createResponseAction({action, fallback})
  url = "#{url}/:#{idKey}" unless url.includes(':#{idKey}')
  pathKeys = [idKey]
  createRunResponse({action: responseAction, url, pathKeys, method: 'DELETE', params...})

# RESTful Resource
# GET /resource
export createRunShow = ({action, fallback = null, params...}) ->
  responseAction = createResponseAction({action, fallback})
  createRunResponse({action: responseAction, method: 'GET', params...})

# POST /resource
export createRunCreate = ({action, fallback = null, params...}) ->
  responseAction = createResponseAction({action, fallback})
  createRunResponse({action: responseAction, method: 'POST', params...})

# PATCH /resource
export createRunUpdate = ({action, fallback = null, params...}) ->
  responseAction = createResponseAction({action, fallback})
  createRunResponse({action: responseAction, method: 'PATCH', params...})

# DELETE /resource
export createRunDestroy = ({action, fallback = null, params...}) ->
  responseAction = createResponseAction({action, fallback})
  createRunResponse({action: responseAction, method: 'DELETE', params...})











# export createRunNameGet = ({action, fallback = null, url, params...}) ->
#   responseAction = createResponseActionName(action, fallback)
#   url = "#{url}/:name" unless url.includes(':name')
#   createRunResponse({params..., action: responseAction, url, method: 'GET'})

# export createRunNamePost = ({action, fallback = null, url, params...}) ->


#   createRunGetNameResponse({params..., action: responseAction, method: 'GET'})



# export createRunResponseGet = (action, url, allowKeys = []) ->
#   (dispatch, props = {}) ->
#     data = pick(props, allowKeys)
#     response = await fetchJsonGet({url, data})
#     if response.ok
#       dispatch(action, response)
#     else
#       console.error response

# # レスポンスを直接渡すアクションを作成する。
# export createRunResponseGet = (action, url, allowKeys = []) ->
#   (dispatch, props = {}) ->
#     data = pick(props, allowKeys)
#     response = await fetchJsonGet({url, data})
#     if response.ok
#       dispatch(action, response)
#     else
#       console.error response

# export createRunGet = (action, url, allowKeys = []) ->
#   responseAction = createResponseAction(action)
#   createRunResponseGet(responseAction, url, allowKeys)

# export createRunGetPage = (action, url, allowKeys = []) ->
#   responseAction = createResponseActionSetPage(action)
#   createRunResponseGet(responseAction, url, [allowKeys..., 'page', 'per_page'])

# export createRunName = (action, url, allowKeys = []) ->
#   responseAction = createResponseAction(action)
#   createRunResponseGet(responseAction, url, allowKeys)

# export createRunGetWithPagination = (action, url, allowKeys = []) ->
#   (dispatch, props = {}) ->
#     data = _.pick(props, allowKeys)
#     items = []
#     for page in [MIN_PAGE..MAX_PAGE]
#       response = await fetchJsonGet({url, data: {data..., page, per_page: MAX_PER_PAGE, no_sync: true}})
#       if response.ok
#         items = [items..., response.data...]
#         break if items.length >= response.total
#       else
#         console.error response
#         return
#     dispatch(action, items)
