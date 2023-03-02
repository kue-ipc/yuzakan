# グループ

import {text} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import {entityLabel} from '/assets/common/helper.js'

import valueDisplay from '/assets/app/value_display.js'

# Views

export default groupOperation = ({option}) ->
  html.div {key: 'group-operation'}, [
    html.h4 {}, text '操作メニュー'
    html.p {}, text '準備中...'
  ]

