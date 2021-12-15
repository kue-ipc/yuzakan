# Bootstrap Icons for hyperapp

import {h} from './hyperapp.js?v=2.0.19'

export BsIcon = ({name, size = 16, alt, props...}) ->
  svg_props =
    class: ['bi']
    width: size
    height: size
    fill: 'currentColor'

  svg_props.class.push(props.class) if props.class?

  Object.assign(svg_props, role: 'img', 'aria-label': alt) if alt?

  h 'svg', svg_props,
    h 'use', href: "/assets/bootstrap-icons.svg\##{name}"
