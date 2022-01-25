# Octicons for hyperapp

import {h, text} from './hyperapp.js?v=2.0.20'
import octicons from './octicons.js?v=16.2.0'

export default octicon = ({name, size = 24, alt, props...}) ->
  h 'span',
    innerHTML: octicons[name].toSVG {
      width: size
      height: size
      'aria-label': alt
      fill: 'currentColor'
      props...
    }
