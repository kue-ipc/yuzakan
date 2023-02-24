import Pluralize from '/assets/vendor/pluralize.js'

import {listToCamelCase, listToPascalCase, listToSnakeCase, listToKebabCase} from '/assets/common/convert.js'

# Capitalize
export capitalize = (str) ->
  str && str[0].toUpperCase() + str[1..].toLowerCase()

# camelCase
export camelize = (str) ->
  listToCamelCase(strToList(str)...)

# PascalCase
export pascalize = (str) ->
  listToPascalCase(strToList(str)...)

# snake_case
export snakize = (str) ->
  listToSnakeCase(strToList(str)...)

# kebab-case
export kebabize = (str) ->
  listToKebabCase(strToList(str)...)

# names
export pluralize = (str) ->
  Pluralize.plural(str)

# name
export singularize = (str) ->
  Pluralize.singular(str)
