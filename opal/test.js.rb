# frozen_string_literal: true

# use_strict: true
# await: true

# JSModule = Native.import('./hyperapp.js').__await__

# %x{
#   console.log('hoge');
# }

# x = 3

# `import("./rb_hyperapp.js")`
JS.import('./rb_hyperapp.js').__await__

# require 'test_opal2'
# puts 'hello opal!!!'
# win = Native(`window`)

# require 'js'
# require 'native'
# puts JS
# puts JS.class
# # puts $global
# `console`.JS.log(JS[:document].JS.getElementById('test'))
# `console`.JS.log($$.document.getElementById('test').to_n)

# `
# var test = {
#   f: (a, b, {x, y}) => {
#     console.log('test func');
#     console.log(a);
#     console.log(b);
#     console.log(x);
#     console.log(y);
#   }
# }
# `

# test = Native(`test`)
# test.f('abc', 'efg', {x: 3, y: $$.document.getElementById('test')})
