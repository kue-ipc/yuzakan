# 動的な警告の表示と削除

ALERTS_CLASS = 'alerts'

LEVELS_COLOR =
  success: 'success'
  failure: 'warning'
  fatal: 'danger'
  error: 'danger'
  warn: 'warning'
  info: 'info'
  debug: 'secondary'
  unknown: 'primary'

DEFALT_COLOR = 'primary'

export ALERT_LEVELS = [
  'success'
  'failure'
  'fatal'
  'error'
  'warn'
  'info'
  'debug'
  'unknown'
]

# アラートの追加
export alertAdd = (message, level = 'error') ->
  level_color = LEVELS_COLOR[level] ? DEFALT_COLOR
  alert_class = "alert alert-#{level_color} alert-dismissible fade show"

  for alerts in document.getElementsByClassName(ALERTS_CLASS)
    div = document.createElement('div')
    div.className = alert_class
    div.setAttribute('role', 'alert')

    text = document.createTextNode(message)

    button = document.createElement('button')
    button.className = 'close'
    button.setAttribute('type', 'button')
    button.setAttribute('data-dismiss', 'alert')
    button.setAttribute('aria-label', '閉じる')

    span = document.createElement('span')
    span.setAttribute('aria-hidden', 'true')

    i = document.createElement('i')
    i.className = 'fas fa-times'

    span.appendChild(i)
    button.appendChild(span)
    div.appendChild(button)
    div.appendChild(text)
    alerts.appendChild(div)

# 全アラートを削除
export alertClear = ->
  for alerts in document.getElementsByClassName(ALERTS_CLASS)
    alerts.removeChild(alerts.firstChild) while alerts.firstChild
