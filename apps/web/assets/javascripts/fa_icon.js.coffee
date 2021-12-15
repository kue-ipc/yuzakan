# fontawesome hyperapp icon

import {h} from './hyperapp.js?v=2.0.19'
import {fas} from './fontawesome-free-solid-svg-icons.js?v=5.15.4'
import {far} from './fontawesome-free-regular-svg-icons.js?v=5.15.4'
import {camelize} from './string_utils.js?v=0.0.1'

export FaIcon = ({prefix, name, options = []}) ->
  name = camelize(name)
  data =
    switch prefix
      when 'fas'
        fas[name]
      when 'far'
        far[name]
      else
        throw "unsupported prefix: #{prefix}"
  data ? throw "not found icon: #{data}"

  iconName = data.iconName
  width = data.icon[0]
  height = data.icon[1]
  iconPath = data.icon[4]

  # data-fa-i2svg 属性をつけるとhyperapp側に操作されてしまい
  # VDOMが更新されなくなるので、つけてはならない。
  h 'svg',
    class: [
      'svg-inline--fa'
      "fa-#{iconName}"
      "fa-w-#{width / 32}"
      options...
    ]
    'aria-hidden': 'true'
    focusable: 'false'
    'data-prefix': prefix
    'data-icon': iconName
    role: 'img'
    xmlns: 'http://www.w3.org/2000/svg'
    viewBox: "0 0 #{width} #{height}"
    h 'path',
      fill: 'currentColor'
      d: iconPath

export FasIcon = (props) ->
  FaIcon({prefix: 'fas', props...})

export FarIcon = (props) ->
  FaIcon({prefix: 'far', props...})
