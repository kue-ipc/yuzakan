import HttpLinkHeader from '/assets/vendor/http-link-header.js'

import {isPresent, objToJson, toInteger} from '/assets/common/utils.js'
import {formDataToJson, formDataToUrlencoded, objToUrlencoded} from '/assets/common/form_helper.js'

import {extractPagination} from './pagination.js'

ALLOWED_METHODS = ['GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE']

export fetchJson = (params) ->
  request = createRequest(params)
  console.debug 'fetch request: %s %s', request.method, request.url
  response = await fetch request
  console.debug 'fetch response: %d %s', response.status, response.url
  parseResponse(response)

export fetchJsonGet = (params) ->
  await fetchJson({method: 'GET', params...})

export fetchJsonHead = (params) ->
  await fetchJson({method: 'HEAD', params...})

export fetchJsonPost = (params) ->
  await fetchJson({method: 'POST', params...})

export fetchJsonPut = (params) ->
  await fetchJson({method: 'PUT', params...})

export fetchJsonPatch = (params) ->
  await fetchJson({method: 'PATCH', params...})

export fetchJsonDelete = (params) ->
  await fetchJson({method: 'DELETE', params...})

createRequest = ({url, method, data = null, type = 'json', params...}) ->
  # create request

  method = method.toUpperCase()
  unless ALLOWED_METHODS.includes(method)
    throw new Error("Unknown or unsupported method: #{method}")

  init = {
    method: method
    mode: 'same-origin'
    credentials: 'same-origin'
    params...
  }

  headers = new Headers {
    'Accept': 'application/json'
  }
 
  if isPresent(data)
    if ['POST', 'PUT', 'PATCH', 'DELETE'].includes(method)
      switch type
        when 'json'
          content_type = 'application/json'
          if data instanceof FormData
            data = formDataToJson(data)
          else if typeof data != 'string'
            data = objToJson(data)
        when 'urlencoded'
          content_type = 'application/x-www-form-urlencoded'
          if data instanceof FormData
            data = formDataToUrlencoded(data)
          else if typeof data != 'string'
            data = objToUrlencoded(data)
        when 'form-data'
          content_type = 'multipart/form-data'
          unless data intanceof FormData
            throw new Error('Not implument')
        when 'text'
          content_type = 'text/plain'
          data = String(data)
        else
          throw new Error("Unknown or unsupported type: #{type}")
      headers.append('Content-Type', content_type)
      headers.append('Content-Length', data.length.toString())
      init.body = data
    else
      if data instanceof FormData
        query = formDataToUrlencoded(data)
      else if typeof data == 'object'
        query = objToUrlencoded(data)
      else
        query = encodeURIComponent(data)
      url += '?' + query

  init.headers = headers

  new Request(url, init)

parseResponse = (response) ->
  location = response.headers.get('Content-Location') ? response.url

  contentType = response.headers.get('Content-Type')
  responseData =
    if not contentType?
      {type: undefined, data: null}
    else if contentType.startsWith('application/json')
      {type: 'json', data: await response.json()}
    else if contentType.startsWith('text/plain')
      {type: 'text', data: await response.text()}
    else
      throw new Error("Unknown or unsupported content type: #{contentType}")

  contentRange = response.headers.get('Content-Range')
  paginationInfo =
    if contentRange?
      {pagination: extractPagination(contentRange, location)}
    else
      {}

  linkHeader = response.headers.get('Link')
  linkInfo =
    if linkHeader?
      {links: HttpLinkHeader.parse(linkHeader)}
    else
      {}

  {
    ok: response.ok
    code: toInteger(response.status)
    location
    responseData...
    paginationInfo...
    linkInfo...
  }