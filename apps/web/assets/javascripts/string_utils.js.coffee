export capitalize = (str) ->
  str && str[0].toUpperCase() + str[1..].toLowerCase()

export listToCamel = (list...) ->
  (list[0]?.toLowerCase() ? '') +
    [capitalize(str) for str in list[1..]].join('')

export listToPascal = (list...) ->
  [capitalize(str) for str in list].join('')

export listToSnake = (list...) ->
  [str.toLowerCase().replace(/-/g, '_') for str in list].join('_')

export listToKebab = (list...) ->
  [str.toLowerCase().replace(/_/g, '-') for str in list].join('-')

export listToField = (list...) ->
  (list[0] ? '') +
    ["[#{str}]" for str in list[1..]].join('')

# camelCase
export camelize

# PascalCase
export pascalize

# snake_case
export snakize

# kebab-case
export kebabize

# form[case]
export formize
