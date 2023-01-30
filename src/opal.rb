# await: true

require 'js'
require 'native'
require 'promise/v2'
require 'await'

module JS
  def import(module_name)
    `import(#{module_name})`
  end
end

module Native
  def self.import(module_name)
    Native(JS.import(module_name).__await__)
  end
end

Promise = PromiseV2

JS[:Opal]
