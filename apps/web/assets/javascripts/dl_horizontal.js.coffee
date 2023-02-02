import * as html from '/assets/vendor/hyperapp-html.js'
import {join} from './class_prop.js'

cols = {
  xs: 12
  sm: 4
  md: 3
  lg: 2
  xl: 2
  xll: 2
}
colPrint = 3

calcDtClasses = ->
  list = []
  list.push "col-#{cols.xs}" if cols.xs && cols.xs < 12
  pre = cols.xs
  for name in ['sm', 'md', 'lg', 'xl', 'xll']
    list.push "col-#{name}-#{cols[name]}" if cols[name] != pre
    pre = cols[name]
  list.push "col-print-#{colPrint}"
  list

calcDdClasses = ->
  list = []
  list.push "col-#{12 - cols.xs}" if cols.xs && cols.xs < 12
  pre = cols.xs
  for name in ['sm', 'md', 'lg', 'xl', 'xll']
    list.push "col-#{name}-#{12 - cols[name]}" if cols[name] != pre
    pre = cols[name]
  list.push "col-print-#{12 - colPrint}"
  list

calcDdSubClasses = ->
  list = calcDdClasses()
  list.push "offset-#{cols.xs}" if cols.xs && cols.xs < 12
  pre = cols.xs
  for name in ['sm', 'md', 'lg', 'xl', 'xll']
    list.push "offset-#{name}-#{cols[name]}" if cols[name] != pre
    list.push "col-#{name}-#{12 - cols[name]}" if cols[name] != pre
    pre = cols[name]
  list.push "offset-print-#{colPrint}"
  list.push "col-print-#{12 - colPrint}"
  list

export dlClasses = Object.freeze ['row']
export dtClasses = Object.freeze calcDtClasses()
export ddClasses = Object.freeze calcDdClasses()
export ddSubClasses = Object.freeze calcDdSubClasses()

export dl = (props, children) ->
  html.dl {
    props...
    class: join(dlClasses, props.class)
  }, children

export dt = (props, children) ->
  html.dt {
    props...
    class: join(dtClasses, props.class)
  }, children

export dd = (props, children) ->
  html.dd {
    props...
    class: join(ddClasses, props.class)
  }, children

export ddSub = (props, children) ->
  html.dd {
    props...
    class: join(ddSubClasses, props.class)
  }, children
