import {text} from 'hyperapp'
import * as html from '@hyperapp/html'

import bsIcon from '~/app/bs_icon.js'
import {convertToType, objToJson} from '~/common/convert.js'

export default valueDisplay = ({value, type = 'string', color = 'body', na = false}) ->
  unless value?
    return html.span {class: 'text-muted'}, text if na then'N/A' else ''

  value = convertToType(value, type)
  html.span {class: "text-#{color}"},
    switch type
      when 'string', 'text', 'date', 'time'
        text value
      when 'boolean'
        if value then bsIcon({name: 'check-square'}) else bsIcon({name: 'square'})
      when 'integer', 'float', 'datatime'
        text String(value)
      when 'date', 'time'
        text value
      when 'list', 'map', 'set'
        text objToJson(value)
