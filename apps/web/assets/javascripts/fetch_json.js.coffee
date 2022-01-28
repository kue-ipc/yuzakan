export fetchJson = (url, {method, body}) ->
  fetchInit =
    method: method
    mode: 'same-origin'
    credentials: 'same-origin'
    headers:
      'Accept': 'application/json'
  fetchInit.body = body if body?
  response = await fetch url, fetchInit
  data = await response.json()
  {
    ok: response.ok
    status: response.status
    data
  }

export fetchJsonGet = (url) ->
  await fetchJson(url, method: 'GET')

export fetchJsonHead = (url) ->
  await fetchJson(url, method: 'HEAD')

export fetchJsonPost = (url, {body}) ->
  await fetchJson(url, method: 'POST', body: body)

export fetchJsonPut = (url, {body}) ->
  await fetchJson(url, method: 'PUT', body: body)

export fetchJsonPatch = (url, {body}) ->
  await fetchJson(url, method: 'PATCH', body: body)

export fetchJsonDelete = (url, {body}) ->
  await fetchJson(url, method: 'DELETE')
