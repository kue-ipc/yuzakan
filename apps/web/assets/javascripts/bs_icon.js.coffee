# Bootstrap Icons for hyperapp

import * as svg from '/assets/vendor/hyperapp-svg.js'

export default BsIcon = ({name, size = 24, alt, props...}) ->
  svg_props = {
    class: ['bi']
    width: size
    height: size
    fill: 'currentColor'
  }

  svg_props.class.push(props.class) if props.class?

  svg_props = {svg_props..., role: 'img', 'aria-label': alt} if alt?

  svg.svg svg_props,
    svg.use {href: "/assets/bootstrap-icons.svg\##{name}"}
