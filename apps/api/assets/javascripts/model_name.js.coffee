import {snakize, pluralize} from '../string_utils.js'

export default class ModelName
  constructor: (@klass) ->
    @name = @klass.name

    @singular = snakize(@name)
    @plural = pluralize(@singular)

    @param_key = @singular
    @singular_route_key = @singular
    @element = @singular

    @collection = @plural
    @route_key = @plural
