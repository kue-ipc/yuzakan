import {text} from '~/vendor/hyperapp.js'
import * as html from '~/vendor/hyperapp-html.js'

import {compact} from '~/common/helper.js'

# page navigatino view
export default pageNav = ({page, per_page, total, start, end, onpage, readonly = false}) ->
  if total
    total_page = Math.ceil(total / per_page)
    html.nav {class: 'd-flex', 'aria-label': 'ページナビゲーション'}, [
      html.ul {class: 'pagination'},
        pageList {page, total_page, onpage, readonly}
      html.p {class: 'ms-2 mt-2'},
        text "#{start + 1} - #{end + 1} / #{total} (#{page} / #{total_page} ページ)"
    ]
  else
    html.nav {class: 'd-flex', 'aria-label': 'ページナビゲーション'}, [
      html.ul {class: 'pagination'}, [
        pageItem {content: 'first', page: 1, disabled: true, onpage, readonly}
        pageItem {content: 'prev', page: 1, disabled: true, onpage, readonly}
        pageItem {content: 'next', page: 1, disabled: true, onpage, readonly}
        pageItem {content: 'last', page: 1, disabled: true, onpage, readonly}
      ]
    ]



pageList = ({page, total_page, onpage, readonly = false}) ->
  compact([
    pageItem {content: 'first', page: 1, disabled: page == 1, onpage, readonly}
    pageItem {content: 'prev', page: page - 1, disabled: page == 1, onpage, readonly}
    pageEllipsis {start: 1, end: page - 3, onpage, readonly}
    (pageNumList {start: page - 2, end: page + 2, page, total_page, onpage, readonly})...
    pageEllipsis {start: page + 3, end: total_page, onpage, readonly}
    pageItem {content: 'next', page: page + 1, disabled: page == total_page, onpage, readonly}
    pageItem {content: 'last', page: total_page, disabled: page == total_page, onpage, readonly}
  ])

pageNumList = ({start, end, page, total_page, onpage, readonly = false}) ->
  for num in [start..end]
    if num > 0 && num <= total_page
      pageItem {content: num, page: num, active: page == num, onpage, readonly}
    else
      null

pageItem = ({content, page, onpage, active = false, disabled = false, readonly = false}) ->
  html.li {key: "page[#{content}]", class: {'page-item': true, active, disabled}},
    html.button {
      type: 'button'
      class: 'page-link'
      disabled: readonly
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

pageEllipsis = ({start, end, onpage, readonly = false}) ->
  if start > end
    return null
  else if start == end
    pageItem {content: start, page: start, onpage, readonly}
  else
    html.li {key: "page[#{start}..#{end}]", class: ['page-item', 'disabled']},
      html.span {class: 'page-link'}, text '...'
