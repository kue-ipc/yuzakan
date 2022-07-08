deepFreeze = (obj) ->
  if obj instanceof Array
    deepFreeze value for value in obj
  else if obj instanceof Map
    deepFreeze value for value from obj.values
  else if obj instanceof Object
    deepFreeze value for own key, value of obj
  Object.freeze(obj)

export ATTR_TYPES = deepFreeze [
  {name: 'string', value: 'string', label: '文字列'}
  {name: 'boolean', value: 'boolean', label: '真偽値'}
  {name: 'integer', value: 'integer', label: '整数'}
  {name: 'float', value: 'float', label: '小数点数'}
  {name: 'datetime', value: 'datetime', label: '日時'}
  {name: 'date', value: 'date', label: '日付'}
  {name: 'time', value: 'time', label: '時刻'}
  {name: 'list', value: 'list', label: 'リスト'}
  {name: 'text', value: 'text', label: '文章'}
]

export MAPPING_CONVERSIONS = deepFreeze [
  {name: '', value: null, label: '変換無し'}
  {name: 'posix_time', value: 'posix_time', label: 'POSIX時間'}
  {name: 'posix_date', value: 'posix_date', label: 'POSIX日付'}
  {name: 'path', value: 'path', label: 'PATH(パス)'}
  {name: 'e2j', value: 'e2j', label: '英日'}
  {name: 'j2e', value: 'j2e', label: '日英'}
]

export CLEARANCE_LEVELS = deepFreeze [
  {name: 'supervisor', value: 5, label: '特権管理者'}
  {name: 'administrator', value: 4, label: '管理者'}
  {name: 'operator', value: 3, label: '操作者'}
  {name: 'monitor', value: 2, label: '監視者'}
  {name: 'user', value: 1, label: '一般ユーザー'}
  {name: 'guest', value: 0, label: 'ゲスト'}
]
