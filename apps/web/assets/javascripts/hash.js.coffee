import XXH from './xxhashjs.js'

export xxh32 = (str) ->
  XXH.h32(str, 0).toString(16)

export xxh64 = (str) ->
  XXH.h64(str, 0).toString(16)
