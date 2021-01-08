# rollup config

import nodeResolve from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'
import coffeeScript from 'rollup-plugin-coffee-script'

srcDir = 'src'
distDirs = [
  'vendor/assets/javascripts'
]
targets = [
  {name: 'hyperapp', ext: 'coffee'}
  {name: 'hyperapp-events', ext: 'coffee'}
  {name: 'bootstrap-native', ext: 'coffee'}
  {name: 'zxcvbn', ext: 'coffee'}
  {name: 'fontawesome', ext: 'coffee'}
  {name: 'fontawesome-svg-core', ext: 'coffee'}
  {name: 'fontawesome-free-regular-svg-icons', ext: 'coffee'}
  {name: 'fontawesome-free-solid-svg-icons', ext: 'coffee'}
]

export default targets.map (target) ->
  input: "#{srcDir}/#{target.name}.#{target.ext ? 'js'}"
  output: distDirs.map (dir) ->
    file: "#{dir}/#{target.name}.js"
    format: 'esm'
  plugins: [
    nodeResolve(
      moduleDirectories: ['node_modules']
    ),
    commonjs(
      include: /node_modules/
    ),
    if target.ext == 'coffee' then coffeeScript() else undefined
  ]
