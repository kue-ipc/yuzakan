# Bootstrap Icons for hyperapp

import {svg, use} from './hyperapp-svg.js?v=0.6.0'

export default BsIcon = ({name, size = 24, alt, props...}) ->
  svg_props = {
    class: ['bi']
    width: size
    height: size
    fill: 'currentColor'
  }

  svg_props.class.push(props.class) if props.class?

  svg_props = {svg_props..., role: 'img', 'aria-label': alt} if alt?

  svg svg_props,
    use {href: "/assets/bootstrap-icons.svg\##{name}"}
