# Createer functions for Hyperapp object and fetch api

import {pick, pickType, identity} from '/assets/common/utils.js'
import csrf from '/assets/csrf.js'

import {fetchJson} from '/assets/api/fetch_json.js'
import {DEFAULT_PAGE, DEFAULT_PER_PAGE} from './pagination.js'
# create Actions

# データを受け取るアクションからレスポンスに対応した新しいアクションを作成する。
# 404の場合はnull、それ以外はエラーでfallbackを実行する。
export createResponseAction = ({action, fallback, normalizer}) ->
  normalizer ?= identity
  (state, response) ->
    if response.ok
      [action, normalizer(response.data)]
    else if response.code == 404
      console.warn response
      [action, null]
    else
      console.error response
      if fallback?
        [fallback, normalizer(response.data)]
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
      [
        {state..., pagination: response.pagination}
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
export createRunResponse = ({
  action
  url: defaultUrl, pathKeys = []
  data: defaultData = {}, dataTypes = []
  method
  params...
}) ->
  (dispatch, props = {}) ->
    url = defaultUrl
    for key in pathKeys
      unless key of props
        console.error 'given props does not have the property for path: %s', key
        return
      url = url.replace(":#{key}", props[key])

    data = {defaultData..., pickType(props, dataTypes)...}
    if ['POST', 'PUT', 'PATCH', 'DELETE'].includes(method.toUpperCase())
      data = {data..., csrf()...}

    response = await fetchJson({method, url, data, params...})
    dispatch(action, response)

# RESTful Resources
# GET /resources
export createRunIndex = ({action, fallback, normalizer, params...}) ->
  responseAction = createResponseAction({action, fallback, normalizer})
  createRunResponse({action: responseAction, method: 'GET', params...})

# GET /resources?page=x&per_page=y
export createRunIndexWithPage = ({action, fallback, normalizer, data = {}, params...}) ->
  responseAction = createResponseActionSetPage({action, fallback, normalizer})
  data = {page: DEFAULT_PAGE, per_page: DEFAULT_PER_PAGE, data...}
  createRunResponse({action: responseAction, data, method: 'GET', params...})

# GET /resources/:id
export createRunShowWithId = ({action, fallback, normalizer, url, idKey = 'id', params...}) ->
  responseAction = createResponseAction({action, fallback, normalizer})
  url = "#{url}/:#{idKey}" unless url.includes(':#{idKey}')
  pathKeys = [idKey]
  createRunResponse({action: responseAction, url, pathKeys, method: 'GET', params...})

# POST /resources
export createRunCreateWithId = ({action, fallback, normalizer, idKey = 'id', setId = false, params...}) ->
  responseAction = if setId
    createResponseActionSetId({action, fallback, normalizer, idKey})
  else
    createResponseAction({action, fallback, normalizer})
  createRunResponse({action: responseAction, method: 'POST', params...})

# PATCH /resources/:id
export createRunUpdateWithId = ({action, fallback, normalizer, url, idKey = 'id', setId = false, params...}) ->
  responseAction = if setId
    createResponseActionSetId({action, fallback, normalizer, idKey})
  else
    createResponseAction({action, fallback, normalizer})
  url = "#{url}/:#{idKey}" unless url.includes(':#{idKey}')
  pathKeys = [idKey]
  createRunResponse({action: responseAction, url, pathKeys, method: 'PATCH', params...})

# DELETE /resources/:id
export createRunDestroyWithId = ({action, fallback, normalizer, url, idKey = 'id', params...}) ->
  responseAction = createResponseAction({action, fallback, normalizer})
  url = "#{url}/:#{idKey}" unless url.includes(':#{idKey}')
  pathKeys = [idKey]
  createRunResponse({action: responseAction, url, pathKeys, method: 'DELETE', params...})

# RESTful Resource
# GET /resource
export createRunShow = ({action, fallback, normalizer, params...}) ->
  responseAction = createResponseAction({action, fallback, normalizer})
  createRunResponse({action: responseAction, method: 'GET', params...})

# POST /resource
export createRunCreate = ({action, fallback, normalizer, params...}) ->
  responseAction = createResponseAction({action, fallback, normalizer})
  createRunResponse({action: responseAction, method: 'POST', params...})

# PATCH /resource
export createRunUpdate = ({action, fallback, normalizer, params...}) ->
  responseAction = createResponseAction({action, fallback, normalizer})
  createRunResponse({action: responseAction, method: 'PATCH', params...})

# DELETE /resource
export createRunDestroy = ({action, fallback, normalizer, params...}) ->
  responseAction = createResponseAction({action, fallback, normalizer})
  createRunResponse({action: responseAction, method: 'DELETE', params...})
