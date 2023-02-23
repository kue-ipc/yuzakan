import {text} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import {compact} from '/assets/common/utils.js'

# page navigatino view
export default pageNav = ({page, per_page, total, start, end, onpage}) ->
  return html.div {} unless total

  total_page = Math.ceil(total / per_page)

  html.nav {class: 'd-flex', 'aria-label': 'ページナビゲーション'}, [
    html.ul {class: 'pagination'},
      pageList {page, total_page, onpage}
    html.p {class: 'ms-2 mt-2'},
      text "#{start} - #{end} / #{total} (#{page} / #{total_page} ページ)"
  ]

pageList = ({page, total_page, onpage}) ->
  compact([
    pageItem {content: 'first', page: 1, disabled: page == 1, onpage}
    pageItem {content: 'prev', page: page - 1, disabled: page == 1, onpage}
    pageEllipsis {start: 1, end: page - 3, onpage}
    (pageNumList {start: page - 2, end: page + 2, page, total_page, onpage})...
    pageEllipsis {start: page + 3, end: total_page, onpage}
    pageItem {content: 'next', page: page + 1, disabled: page == total_page, onpage}
    pageItem {content: 'last', page: total_page, disabled: page == total_page, onpage}
  ])

pageNumList = ({start, end, page, total_page, onpage}) ->
  for num in [start..end]
    if num > 0 && num <= total_page
      pageItem {content: num, page: num, active: page == num, onpage}
    else
      null

pageItem = ({content, page, active = false, disabled = false, onpage}) ->
  html.li {key: "page[#{content}]", class: {'page-item': true, active, disabled}},
    html.button {
      type: 'button'
      class: 'page-link'
      onclick: (state) -> [onpage, page]
    }, text pageText(content)

pageText = (content) ->
  if typeof content == 'string'
    {
      first: '最初'
      last: '最後'
      prev: '前'
      next: '次'
    }[content] || content
  else
    String(content)

pageEllipsis = ({start, end, onpage}) ->
  if start > end
    return null
  else if start == end
    pageItem(content: start, page: start, onpage)
  else
    html.li {key: "page[#{start}..#{end}]", class: ['page-item', 'disabled']},
      html.span {class: 'page-link'}, text '...'
