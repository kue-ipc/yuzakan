export capitalize = (str) ->
  str && str[0].toUpperCase() + str[1..].toLowerCase()

export listToCamel = (list...) ->
  (list[0]?.toLowerCase() ? '') +
    (capitalize(str) for str in list[1..]).join('')

export listToPascal = (list...) ->
  (capitalize(str) for str in list).join('')

export listToSnake = (list...) ->
  (str.toLowerCase().replace(/-/g, '_') for str in list).join('_')

export listToKebab = (list...) ->
  (str.toLowerCase().replace(/_/g, '-') for str in list).join('-')

export listToField = (list...) ->
  (list[0] ? '') +
    ("[#{str}]" for str in list[1..]).join('')

export strToList = (str) ->
  str.replace(/[A-Z]+/g, '_$&').toLowercCase().split(/[-_\s]+/)

# camelCase
export camelize = (str) ->
  listToCamel(strToList(str))

# PascalCase
export pascalize = (str) ->
  listToPascal(strToList(str))

# snake_case
export snakize = (str) ->
  listToSnake(strToList(str))

# kebab-case
export kebabize = (str) ->
  listToKebab(strToList(str))

# form[field][name]
export fieldize = (str) ->
  listToField(strToList(str))
