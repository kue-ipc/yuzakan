import {dl, dt, dd} as html from './hyperapp-html.js'

cols = {
  xs: 12
  sm: 4
  md: 3
  lg: 2
  xl: 2
  xll: 2
}

calcDtClasses = ->
  list = []
  list.push "col-#{cols.xs}" if cols.xs && cols.xs < 12
  pre = cols.xs
  for name in ['sm', 'md', 'lg', 'xl', 'xll']
    list.push "col-#{name}-#{cols[name]}" if cols[name] != pre
    pre = cols[name]
  list

calcDdClasses = ->
  list = []
  list.push "col-#{12 - cols.xs}" if cols.xs && cols.xs < 12
  pre = cols.xs
  for name in ['sm', 'md', 'lg', 'xl', 'xll']
    list.push "col-#{name}-#{12 - cols[name]}" if cols[name] != pre
    pre = cols[name]
  list

calcDdSubClasses = ->
  list = calcDdClasses()
  list.push "offset-#{cols.xs}" if cols.xs && cols.xs < 12
  pre = cols.xs
  for name in ['sm', 'md', 'lg', 'xl', 'xll']
    list.push "offset-#{name}-#{cols[name]}" if cols[name] != pre
    pre = cols[name]
  list

export DL_CLASSES = Object.freeze ['row']
export DT_CLASSES = Object.freeze calcDtClasses()
export DD_CLASSES = Object.freeze calcDdClasses()
export DD_SUB_CLASSES = Object.freeze calcDdSubClasses()

export dl = (props) ->
  if !props.class?
    []
  html.dl {

  }
