import {text} from './hyperapp.js'
import * as html from './hyperapp-html.js'

import BsIcon from './bs_icon.js'

export default valueDisplay = ({value, type = 'string', color = 'body', na = true}) ->
  unless value?
    return html.span {class: 'text-muted'}, text if na then'N/A' else ''

  html.span {class: "text-#{color}"},
    switch type
      when 'string', 'text'
        text value
      when 'boolean'
        if value then BsIcon({name: 'check-square'}) else BsIcon({name: 'square'})
      when 'integer'
        text String(value)
      when 'float'
        text String(value)
      when 'datetime'
        text String(value)
      when 'date'
        text String(value)
      when 'time'
        text String(value)
      when 'list'
        text String(value)