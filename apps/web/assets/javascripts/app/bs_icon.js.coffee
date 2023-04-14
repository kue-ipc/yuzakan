# Bootstrap Icons for hyperapp

import * as svg from '@hyperapp/svg'

export default bsIcon = ({name, size = 24, alt, props...}) ->
  svg_props = {
    class: ['bi']
    width: size
    height: size
    fill: 'currentColor'
  }

  svg_props.class.push(props.class) if props.class?

  svg_props = {svg_props..., role: 'img', 'aria-label': alt} if alt?

  svg.svg svg_props,
    svg.use {href: "/assets/vendor/bootstrap-icons.svg\##{name}"}
