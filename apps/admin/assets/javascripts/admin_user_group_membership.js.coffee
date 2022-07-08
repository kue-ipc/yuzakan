import {text} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

export default groupMembership = ({mode, user}) ->
  html.div {}, [
    html.h4 {}, text '所属グループ'
  ]
