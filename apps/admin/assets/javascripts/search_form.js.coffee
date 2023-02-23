import {text} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import BsIcon from '/assets/app/bs_icon.js'

export default searchForm = ({query, onsearch}) ->
  searchInput = html.input {
    class: 'form-control'
    type: 'search'
    value: query
    placeholder: '検索...'
    onkeypress: (state, event) ->
      if event.keyCode == 13
        [onsearch, event.target.value]
      else
        state
  }

  html.div {class: 'row mb-3'}, [
    html.div {class: 'col-md-3'},
      html.div {class: 'input-group'}, [
        searchInput
        html.button {
          type: 'button'
          class: 'btn btn-outline-secondary'
          onclick: (state) -> [onsearch, searchInput.node.value]
        }, BsIcon({name: 'search'})
      ]
    html.div {class: 'col-md-3'}, [
      html.input {
        id: 'search-query'
        type: 'text'
        class: 'form-control-plaintext'
        value: query
      }
    ]
  ]
