import {text} from 'hyperapp'
import * as html from '@hyperapp/html'
import bsIcon from '~/app/bs_icon.js'

STATUSES = new Map([
  {status: 'success', label: '成功', color: 'success', icon: 'check-circle-fill'}
  {status: 'failure', label: '失敗', color: 'danger', icon: 'x-circle-fill'}
  {status: 'fatal', label: '致命的エラー', color: 'danger', icon: 'slash-circle-fill'}
  {status: 'error', label: 'エラー', color: 'danger', icon: 'exclamation-octagon-fill'}
  {status: 'warn', label: '警告', color: 'warning', icon: 'exclamation-triangle-fill'}
  {status: 'info', label: '情報', color: 'info', icon: 'info-square-fill'}
  {status: 'debug', label: 'デバッグ', color: 'secondary', icon: 'bug-fill'}
  {status: 'alert', label: 'アラート', color: 'danger', icon: 'exclamation-triangle-fill'}
  {status: 'caution', label: '注意', color: 'warning', icon: 'exclamation-triangle-fill'}
  {status: 'unknown', label: '不明', color: 'primary', icon: 'question-diamond-fill'}
].map((status) -> [status.status, status]))

UNKNOWN_STATUS = 'unknown'
RUNNING_LABEL = '読込中...'

export StatusIcon = ({status, props...}) ->
  if status == 'running'
    html.div {class: "spinner-border #{props.class}", role: 'status'},
      html.span {class: 'visually-hidden'}, text RUNNING_LABEL
  else
    {label, color, icon} = statusInfo(status)
    html.div {class: "text-#{color} #{props.class}"},
      bsIcon {name: icon, alt: label, size: 32}

export statusInfo = (status) ->
  STATUSES.get(status) ? STATUSES.get(UNKNOWN_STATUS)
