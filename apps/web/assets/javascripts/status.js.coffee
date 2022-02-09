import {h, text} from './hyperapp.js?v=0.6.0'


STATUSES = new Map([
  {status: 'success', label: '成功', color: 'success', icon: 'check-circle-fill'}
  {status: 'failure', label: '失敗', color: 'danger', icon: 'x-circle-fill'}
  {status: 'fatal', label: '致命的エラー', color: 'danger', icon: 'slash-circle-fill'}
  {status: 'error', label: 'エラー', color: 'danger', icon: 'exclamation-octagon-fill'}
  {status: 'warn', label: '警告', color: 'warning', icon: 'exclamation-triangle-fill'}
  {status: 'info', label: '情報', color: 'info', icon: 'info-square-fill'}
  {status: 'debug', label: 'デバッグ', color: 'secondary', icon: 'bug-fill'}
  {status: 'unknown', label: '不明', color: 'primary', icon: 'question-diamond-fill'}
].map((status) -> [status.status, status]))

UNKNOWN_STATUS = 'unknown'
RUNNING_LABEL = '読込中...'

export StatusIcon = ({status}) ->
  if status == 'running'
    return h 'div', {class: 'spinner-border', role: 'status'},
      h 'span', {class: 'visually-hidden'}, text RUNNING_LABEL

  {label, color, icon} = statusInfo(status)
  h 'span', {class: ["text-#{color}", 'align-text-bottom']},
    BsIcon {name: icon, size: 24, alt: label}

export statusInfo = (status) ->
  STATUSES.get(status) ? STATUSES.get(UNKNOWN_STATUS)
