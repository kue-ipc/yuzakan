import {text} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

import {DL_CLASSES, DT_CLASSES, DD_CLASSES} from '../dl_horizontal.js'
import {CLEARANCE_LEVELS} from '../definition.js'

export default basicInfo = ({mode, user}) ->
  html.div {}, [
    html.h4 {}, text '基本情報'
    html.dl {class: DL_CLASSES}, [
      html.dt {class: DT_CLASSES},
        html.label {class: 'form-label', for: 'user-name'}, text 'ユーザー名'
      html.dd {class: DD_CLASSES},
        switch mode
          when 'new'
            html.input {
              id: 'user-name'
              class: 'form-control'
              type: 'text'
              required: true
              value: user.name
              oninput: (state, event) -> [userAction, {user: {name: event.target.value}}]
            }
          when 'edit'
            html.input {
              id: 'user-name'
              class: 'form-control-plaintext'
              readonly: true
              type: 'text'
              value: user.name
            }
          when 'show'
            text user.name
      html.dt {class: DT_CLASSES},
        text '表示名'
      html.dd {class: DD_CLASSES},
        if mode == 'new'
          html.span {class: 'text-muted'}, text '(属性値にて設定)'
        else
          text user.display_name ? ''
      html.dt {class: DT_CLASSES},
        text 'メールアドレス'
      html.dd {class: DD_CLASSES},
        if mode == 'new'
          html.span {class: 'text-muted'}, text '(属性値にて設定)'
        else
          text user.email ? ''
      html.dt {class: DT_CLASSES},
        text '権限レベル'
      html.dd {class: DD_CLASSES},
        if mode == 'show'
          text (CLEARANCE_LEVELS.find (level) -> level.value == user.clearance_level).label
        else
          html.select {
            class: 'form-select'
            oninput: (state, event) ->
              [userAction, {user: {clearance_level: parseInt(event.target.value, 10)}}]
          },
            for level in CLEARANCE_LEVELS
              html.option {
                value: level.value
                selected: level.value == user.clearance_level
              }, text level.label
    ]
  ]
