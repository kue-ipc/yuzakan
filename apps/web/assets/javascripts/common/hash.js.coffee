import XXH from 'xxhashjs'

zeroPadding = (str, size) ->
  ('0'.repeat(size) + str).slice(-size)

export xxh32 = (str) ->
  zeroPadding(XXH.h32(str, 0).toString(16), 8)

export xxh64 = (str) ->
  zeroPadding(XXH.h64(str, 0).toString(16), 16)
