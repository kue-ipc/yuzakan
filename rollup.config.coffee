# rollup config

import nodeResolve from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'
import json from '@rollup/plugin-json'

import coffeeScript from 'rollup-plugin-coffee-script'

srcDir = 'src'
distDirs = [
  'vendor/assets/javascripts'
]
targets = [
  {name: 'bootstrap', ext: 'coffee'}
  {name: 'hyperapp', ext: 'coffee'}
  {name: 'hyperapp-dom', ext: 'coffee'}
  {name: 'hyperapp-events', ext: 'coffee'}
  {name: 'hyperapp-html', ext: 'coffee'}
  {name: 'hyperapp-svg', ext: 'coffee'}
  {name: 'hyperapp-time', ext: 'coffee'}
  {name: 'pluralize', ext: 'coffee'}
  {name: 'zxcvbn', ext: 'coffee'}
]

export default (for target in targets
  {
    input: "#{srcDir}/#{target.name}.#{target.ext ? 'js'}"
    output: for dir in distDirs
      {
        file: "#{dir}/#{target.name}.js"
        format: 'esm'
      }
    plugins: [
      nodeResolve({moduleDirectories: ['node_modules']})
      commonjs({include: /node_modules/})
      json()
      coffeeScript() if target.ext == 'coffee'
    ]
  }
)
