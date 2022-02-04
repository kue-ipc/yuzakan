import {fetchJsonGet} from '../fetch_json.js?v=0.6.0'

export default class Model
  @model_name = ->
    @_model_name ?= new ModelName(@)

  constructor: ({@id, created_at, updated_at, @url = null}) ->
    @created_at = new Date(created_at)
    @updated_at = new Date(updated_at)

  @entities = new Map

  @find: (id) ->
    id = Number(id) if typeof id != 'number'
    unless Number.isInteger(id) && id > 0
      throw new TypeError("#{id} is not positive integer nmuber")
    return @entities.get(id) if @entities.has(id)

    url = "/admin/#{@model_name().route_key}/#{id}"
    {ok, status, data} = await fetchJsonGet(url)
    return null unless ok

    entity = new @(data)
    @entities.set(id, data)
    data

  @all: ->
    url = "/admin/#{@model_name().route_key}"
    {ok, status, allData} = await fetchJsonGet(url)
    return null unless ok

    for data in allData
      entity = new @(data)
      @entities.set(entity.id, data)

    @entities.values
  
  @find_by_name: (name) ->
    @all().find (entry) ->
      entry.name == name

  constructor: ({@id, created_at, updated_at}) ->
    @created_at = new Date(created_at)
    @updated_at = new Date(updated_at)
