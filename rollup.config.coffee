# rollup config

import nodeResolve from 'rollup-plugin-node-resolve'
import commonjs from 'rollup-plugin-commonjs'
import coffeeScript from 'rollup-plugin-coffee-script'

srcDir = 'src'
distDirs = [
  'apps/web/vendor/assets/javascripts'
  'apps/admin/vendor/assets/javascripts'
]
targets = [
  {name: 'hyperapp', ext: 'coffee'}
  {name: 'bootstrap-native', ext: 'coffee'}
  {name: 'zxcvbn', ext: 'coffee'}
]

export default targets.map (target) ->
  input: "#{srcDir}/#{target.name}.#{target.ext ? 'js'}"
  output: distDirs.map (dir) ->
    file: "#{dir}/#{target.name}.js"
    format: 'esm'
  plugins: [
    nodeResolve(
      customResolveOptions:
        moduleDirectory: 'node_modules'
    ),
    commonjs(
      include: /node_modules/
    ),
    if target.ext == 'coffee' then coffeeScript() else undefined
  ]
