import Pluralize from '/assets/vendor/pluralize.js'

# abcDef_ghi-jkl -> abc def ghi jkl
export strToList = (str) ->
  str.replace(/[A-Z]+/g, '_$&').toLowerCase().split(/[-_\s]+/)

export listToCamel = (list...) ->
  (list[0]?.toLowerCase() ? '') +
    (capitalize(str) for str in list[1..]).join('')

export listToPascal = (list...) ->
  (capitalize(str) for str in list).join('')

export listToSnake = (list...) ->
  (str.toLowerCase().replace(/-/g, '_') for str in list).join('_')

export listToKebab = (list...) ->
  (str.toLowerCase().replace(/_/g, '-') for str in list).join('-')

# Capitalize
export capitalize = (str) ->
  str && str[0].toUpperCase() + str[1..].toLowerCase()

# camelCase
export camelize = (str) ->
  listToCamel(strToList(str)...)

# PascalCase
export pascalize = (str) ->
  listToPascal(strToList(str)...)

# snake_case
export snakize = (str) ->
  listToSnake(strToList(str)...)

# kebab-case
export kebabize = (str) ->
  listToKebab(strToList(str)...)

# names
export pluralize = (str) ->
  Pluralize.plural(str)

# name
export singularize = (str) ->
  Pluralize.singular(str)
