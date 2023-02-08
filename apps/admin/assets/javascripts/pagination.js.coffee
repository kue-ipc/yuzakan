import {text} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

pageItem = ({content, page, active = false, disabled = false, onpage}) ->
  liClass = ['page-item']
  liClass.push 'active' if active
  liClass.push 'disabled' if disabled
  html.li {class: liClass},
    html.button {
      type: 'button'
      class: 'page-link'
      onclick: (state) -> [onpage, page]
    }, text content

pageEllipsis = ({content = '...'}) ->
  liClass = ['page-item', 'disabled']
  html.li {class: liClass},
    html.span {class: 'page-link'}, text content

export default pagination = ({page, per_page, total, onpage}) ->
  first_page = 1
  last_page = Math.floor(total / per_page) + 1
  total_page = last_page - first_page + 1

  list = []
  list.push(pageItem {content: '最初', page: first_page, disabled: page == first_page, onpage})
  list.push(pageItem {content: '前', page: page - 1, disabled: page == first_page, onpage})

  if last_page <= 5
    list.push(pageItem {content: num, page: num, active: page == num, onpage}) for num in [first_page..last_page]
  else if page <= 3
    list.push(pageItem {content: num, page: num, active: page == num, onpage}) for num in [first_page..5]
    list.push(pageEllipsis {})
  else if last_page - page <= 2
    list.push(pageEllipsis {})
    list.push(pageItem {content: num, page: num, active: page == num, onpage}) for num in [(last_page - 4)..last_page]
  else
    list.push(pageEllipsis {})
    list.push(pageItem {content: num, page: num, active: page == num, onpage}) for num in [(page - 2)..(page + 2)]
    list.push(pageEllipsis {})

  list.push(pageItem {content: '次', page: page + 1, disabled: page == last_page, onpage})
  list.push(pageItem {content: '最後', page: last_page, disabled: page == last_page, onpage})

  html.nav {class: 'd-flex', 'aria-label': 'ページナビゲーション'}, [
    html.ul {class: 'pagination'}, list
    html.p {class: 'ms-2 mt-2'},
      text "#{(page - 1) * per_page + 1} - #{Math.min(page * per_page, total)} / #{total} (#{page} / #{total_page}ページ)"
  ]
