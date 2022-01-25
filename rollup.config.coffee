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
  {name: 'hyperapp', ext: 'coffee'}
  {name: 'bootstrap', ext: 'coffee'}
  {name: 'zxcvbn', ext: 'coffee'}
]

export default targets.map (target) ->
  input: "#{srcDir}/#{target.name}.#{target.ext ? 'js'}"
  output: distDirs.map (dir) ->
    file: "#{dir}/#{target.name}.js"
    format: 'esm'
  plugins: [
    nodeResolve(moduleDirectories: ['node_modules'])
    commonjs(include: /node_modules/)
    json()
    coffeeScript() if target.ext == 'coffee'
  ]
