# rollup config

import coffee from 'rollup-plugin-coffee-script'
import resolve from 'rollup-plugin-node-resolve'

srcDir = 'src'
distDirs = [
  'apps/web/vendor/assets/javascripts'
  'apps/admin/vendor/assets/javascripts'
]
targets = [
  {name: 'hyperapp', ext: 'coffee'}
]

export default targets.map (target) ->
  input: "#{srcDir}/#{target.name}.#{target.ext ? 'js'}"
  output: distDirs.map (dir) ->
    file: "#{dir}/#{target.name}.js"
    format: 'esm'
  plugins: [
    resolve(
      customResolveOptions:
        moduleDirectory: 'node_modules'
    ),
    if target.ext == 'coffee' then coffee() else undefined
  ]
