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
  {name: 'csv', ext: 'coffee'}
  {name: 'es-module-shims', ext: 'coffee'}
  {name: 'file-saver', ext: 'coffee'}
  {name: 'hljs', ext: 'coffee'}
  {name: 'http-link-header', ext: 'coffee'}
  {name: 'hyperapp', ext: 'coffee'}
  {name: 'luxon', ext: 'coffee'}
  {name: 'pluralize', ext: 'coffee'}
  {name: 'ramda', ext: 'coffee'}
  {name: 'xxhashjs', ext: 'coffee'}
  {name: 'zxcvbn', ext: 'coffee'}
]

export default targets.map (target) -> {
  input: "#{srcDir}/#{target.name}.#{target.ext ? 'js'}"
  output: distDirs.map (dir) -> {
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
