# utils

import * as R from '/assets/vendor/ramda.js'

export isNil = R.isNil

export isEmpty = R.isEmpty

export isBlank = (obj) -> isNil(obj) || isEmpty(obj)

export isPresent = R.compose(R.not, isBlank)

export presence = (obj) ->
  if isPresent(obj)
    obj
  else
    null

# TODO 逆にするだけができるはず
export pick = (obj, keys) -> R.pick(keys, obj)


# TODO
# export deepFreeze = (obj)
#   return obj if Object.isFrozen(obj)

#   Object.freeze(obj)
#   switch Object.getPrototypeOf(obj).constructor
#     when Object
#       deepFreeze(value) for own key, value of obj
#     when Array
#       deepFreeze(value) for value in obj
#     when Map
#       deepFreeze(value) for value from obj.values()
#     when Set
#       deepFreeze(value) for value from obj
#   obj

# export clone

# export deepClone

