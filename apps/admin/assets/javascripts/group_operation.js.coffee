# グループ

import {text} from 'hyperapp'
import * as html from '@hyperapp/html'

import {entityLabel} from '~/common/helper.js'

import valueDisplay from '~/app/value_display.js'

# Views

export default groupOperation = ({option}) ->
  html.div {key: 'group-operation'}, [
    html.h4 {}, text '操作メニュー'
    html.p {}, text '準備中...'
  ]

