import {text} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

RemoveGroup = (state, group_name) ->
  {
    state...
    user: {
      state.user...
      groups: (group for group in state.user.groups when group != group_name)
    }
  }

groupLi = ({group_name, groups, removable = false}) ->
  group = groups.find (item) -> item.name == group_name
  html.li {class: 'list-inline-item border border-success rounded px-1 mb-1'}, [
    text "#{group.display_name} (#{group.name})"
    if removable
      html.span {class: 'px-1 rounded-3 ms-1 border boder-dark'},
        html.a {
          href: '#'
          class: 'btn-close'
          onclick: [RemoveGroup, group_name]
        }
    else
      text ''
  ]

export default groupMembership = ({mode, user, groups}) ->
  html.div {}, [
    html.h4 {}, text '所属グループ'
    if user.groups.length == 0
      html.p {}, text '所属しているグループはありません。'
    else
      html.ul {class: 'list-inline'},
        for group_name in user.groups
          groupLi({group_name, groups, removable: group_name != user.primary_group})
    html.button {class: 'btn btn-primary'}, text '追加'
  ]
