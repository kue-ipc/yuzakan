import HttpLinkHeader from '/assets/vendor/http-link-header.js'

import {isPresent, objToJson, toInteger} from '/assets/utils.js'

import {formDataToJson, formDataToUrlencoded, objToUrlencoded} from '/assets/form_helper.js'

export DEFAULT_PAGE = 1
export DEFAULT_PER_PAGE = 20
export MIN_PAGE = 1
export MAX_PAGE = 10000
export MIN_PER_PAGE = 10
export MAX_PER_PAGE = 100

ALLOWED_METHODS = ['GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE']

export fetchJson = ({url, method, data = null, type = 'json', params...}) ->
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

  request = new Request url, init
  console.debug 'fetch %s %s', request.method, request.url
  response = await fetch request

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

  totalCount = response.headers.get('Total-Count')
  pageInfo =
    if totalCount?
      total = toInteger(totalCount)
      contentRange = response.headers.get('Content-Range')
      match = contentRange.match(/^items\s+(?<start>\d+)-(?<end>\d+)\/(?<total>\d+)$/)
      if total != toInteger(match.groups.total)
        console.warn "Do not match Total-Count(#{totalCount}) and size of Content-Range(#{contentRange})"
      {
        page: toInteger(data.page ? DEFAULT_PAGE)
        per_page: toInteger(data.per_page ? DEFAULT_PER_PAGE)
        total
        start: toInteger(match.groups.start)
        end: toInteger(match.groups.end)
      }
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
    location: response.headers.get('Content-Location') ? url
    responseData...
    pageInfo...
    linkInfo...
  }

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
