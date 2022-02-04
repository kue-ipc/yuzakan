export fetchJson = (url, {method, data}) ->
  method = method.toUpperCase()
  unless ['GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE'].includes(method)
    throw new Error("Unknown or unsupported method: #{method}")

  fetchInit =
    method: method
    mode: 'same-origin'
    credentials: 'same-origin'

  headers = new Headers
    'Accept': 'application/json'

  if ['POST', 'PUT', 'PATCH'].includes(method) and data?
    body = JSON.stringify(data)
    headers.append('Content-Type', 'application/json')
    headers.append('Content-Length', body.length.toString())
    fetchInit.body = body

  fetchInit.headers = headers

  response = await fetch url, fetchInit
  data = await response.json()

  {
    ok: response.ok
    status: response.status
    data: data
  }

export fetchJsonGet = (url) ->
  await fetchJson(url, method: 'GET')

export fetchJsonHead = (url) ->
  await fetchJson(url, method: 'HEAD')

export fetchJsonPost = (url, {data}) ->
  await fetchJson(url, method: 'POST', data: data)

export fetchJsonPut = (url, {data}) ->
  await fetchJson(url, method: 'PUT', data: data)

export fetchJsonPatch = (url, {data}) ->
  await fetchJson(url, method: 'PATCH', data: data)

export fetchJsonDelete = (url) ->
  await fetchJson(url, method: 'DELETE')
