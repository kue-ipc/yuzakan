import {filedToList} from './form_helper.js?v=0.6.0'

export fetchJson = (url, {method, data, type = 'json'}) ->
  method = method.toUpperCase()
  unless ['GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE'].includes(method)
    throw new Error("Unknown or unsupported method: #{method}")

  init = {
    method: method
    mode: 'same-origin'
    credentials: 'same-origin'
  }

  headers = new Headers {
    'Accept': 'application/json'
  }

  if data?
    switch type
      when 'json'
        content_type = 'application/json'
        if data instanceof FormData
          data = formDataToJson(data)
        else if typeof data != 'string'
          data = JSON.stringify(data)
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
      else
        throw new Error("Unknown or unsupported type: #{type}")

    if ['POST', 'PUT', 'PATCH'].includes(method)
      headers.append('Content-Type', content_type)
      headers.append('Content-Length', data.length.toString())
      init.body = data
    else if type == 'urlencoded'
      url = url + '?' + data
    else
      throw new Error("Unsupported type for method: #{method}, #{type}")

  init.headers = headers

  request = new Request url, init
  response = await fetch request

  contentType = response.headers.get('Content-Type')
  if not contentType?
    data = null
  if contentType.startsWith('application/json')
    data = await response.json()
  else if contentType.startsWith('text/plain')
    data = await response.text()
  else
    throw new Error("Unknown or unsupported content type: #{contentType}")

  {
    ok: response.ok
    status: response.status
    data: data
  }

export fetchJsonGet = (url, {data = null}) ->
  await fetchJson(url, {method: 'GET', data, type: 'urlencoded'})

export fetchJsonHead = (url, {data = null}) ->
  await fetchJson(url, {method: 'HEAD', data, type: 'urlencoded'})

export fetchJsonPost = (url, {data, type = 'json'}) ->
  await fetchJson(url, {method: 'POST', data, type})

export fetchJsonPut = (url, {data, type = 'json'}) ->
  await fetchJson(url, {method: 'PUT', data, type})

export fetchJsonPatch = (url, {data, type = 'json'}) ->
  await fetchJson(url, {method: 'PATCH', data, type})

export fetchJsonDelete = (url, {data = null}) ->
  await fetchJson(url, {method: 'DELETE', data, type: 'urlencoded'})

formDataToObj = (formData) ->
  obj = {}
  for [key, value] from formData
    names = filedToList(key)
    curObj = obj
    for name in names[0..-2]
      curObj[name] ?= {}
      curObj = curObj[name]
    curObj[names[-1]] = value

formDataToJson = (formData) ->
  JSON.stringify(formDataToObj(formData))

formDataToUrlencoded = (formData) ->
  throw new Error('Not implument')

objToUrlencoded = (obj) ->
  throw new Error('Not implument')

