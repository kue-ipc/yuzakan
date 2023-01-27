require 'js'
require 'native'

module JS
  def import(module_name)
    `import(#{module_name})`
  end
end

module Native
  def self.import(module_name)
    Native(JS.import(module_name))
  end
end

JS[:Opal]
