# Createer functions for Hyperapp object and fetch api

import {pick, pickType} from '/assets/utils.js'

import {fetchJson} from './fetch_json.js'

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
export createResponseActionWithPage = (params) ->
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
export createResponseActionWithId = ({idKey = 'id', params...}) ->
  responseAction = createResponseAction(params)
  runResponseAction = (dispatch, props) -> dispatch(responseAction, props)
  (state, response) ->
    if response.ok
      [
        {state..., id: response.data[idKey]}
        [runResponseAction, response]
      ]
    else
      [responseAction, response]

# create Effecter

# レスポンスを直接渡すアクションを作成する。
# pathKeys内の文字列はそれぞれ部分文字列になっていはいけない。
export createRunResponse = ({action, url, pathKeys = [], dataKeys = [], params...}) ->
  (dispatch, props = {}) ->
    for key in pathKeys
      unless props.hasOwnProperty(key)
        console.error 'given props does not have the property for path: %s', key
        return
      url = url.replace(":#{key}", props[key])
    data = pickType(props, dataKeys)
    response = await fetchJson({params..., url, data})
    dispatch(action, response)

# RESTful Resources
export createRunIndex = ({action, fallback = null, params...}) ->
  responseAction = createResponseAction({action, fallback})
  createRunResponse({params..., action: responseAction, method: 'GET'})

export createRunIndexWithPage = ({action, fallback = null, params...}) ->
  responseAction = createResponseActionWithPage({action, fallback})
  createRunResponse({params..., action: responseAction, method: 'GET'})

export createRunShowWithId = ({action, fallback = null, url, idKey = 'id', params...}) ->
  responseAction = createResponseActionWithId({action, fallback, idKey})
  url = "#{url}/:id" unless url.includes(':id')
  createRunResponse({params..., action: responseAction, url, method: 'GET'})

export createRunCreateWithId = ({action, fallback = null, url, idKey = 'id', params...}) ->
  responseAction = createResponseActionWithId({action, fallback, idKey})
  url = url
  createRunResponse({params..., action: responseAction, url, method: 'POST'})

export createRunUpdateWithId = ({action, fallback = null, url, idKey = 'id', params...}) ->
  responseAction = createResponseActionWithId({action, fallback, idKey})
  url = "#{url}/:id" unless url.includes(':id')
  createRunResponse({params..., action: responseAction, url, method: 'PATCH'})

export createRunDestroyWithId = ({action, fallback = null, url, params...}) ->
  responseAction = createResponseActionWithId({action, fallback, idKey})
  url = "#{url}/:id" unless url.includes(':id')
  createRunResponse({params..., action: responseAction, url, method: 'DELETE'})

# RESTful Resource
export createRunShow = ({action, fallback = null, params...}) ->
  responseAction = createResponseAction({action, fallback})
  createRunResponse({params..., action: responseAction, method: 'GET'})

export createRunCreate = ({action, fallback = null, params...}) ->
  responseAction = createResponseAction({action, fallback, idKey})
  url = path
  createRunResponse({params..., action: responseAction, method: 'POST'})

export createRunUpdate = ({action, fallback = null, params...}) ->
  responseAction = createResponseAction({action, fallback, idKey})
  createRunResponse({params..., action: responseAction, method: 'PATCH'})

export createRunDestroy = ({action, fallback = null, params...}) ->
  responseAction = createResponseAction({action, fallback, idKey})
  createRunResponse({params..., action: responseAction, method: 'DELETE'})











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
#   responseAction = createResponseActionWithPage(action)
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
