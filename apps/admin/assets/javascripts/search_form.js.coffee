import {text} from 'hyperapp'
import * as html from '@hyperapp/html'

import bsIcon from '~/app/bs_icon.js'

export default searchForm = ({query, onsearch, props...}) ->
  searchInput = html.input {
    class: 'form-control'
    type: 'search'
    value: query
    placeholder: '検索...'
    props...
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
        }, bsIcon({name: 'search'})
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
