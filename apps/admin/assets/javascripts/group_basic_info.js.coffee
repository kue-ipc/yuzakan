# グループ

import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import * as dlh from '/assets/app/dl_horizontal.js'
import bsIcon from '/assets/app/bs_icon.js'

# Views

export default groupBasicInfo = ({mode, group}) ->
  html.div {}, [
    html.h4 {}, text '基本情報'
    dlh.dl {}, [
      dlh.dt {},
        text 'グループ名'
      dlh.dd {},
        text group.name
      dlh.dt {},
        text '表示名'
      dlh.dd {},
        text group.display_name ? ''
      dlh.dt {},
        text 'プライマリ'
      dlh.dd {},
        if group.primary
          html.span {class: 'text-success'},
            bsIcon({name: 'check-square'})
        else
          html.span {class: 'text-muted'},
            bsIcon({name: 'square'})
      dlh.dt {},
        text '状態'
      dlh.dd {},
        if group.deleted
          html.span {class: 'text-failure'},
            text "削除済み(#{group.deleted_at})"
        else if group.prohibited
          html.span {class: 'text-muted'},
            text '使用禁止'
        else
          html.span {class: 'text-success'},
            text '正常'
      dlh.dt {},
        text '備考'
      dlh.dd {},
        text group.note ? ''
    ]
  ]
