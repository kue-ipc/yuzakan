# frozen_string_literal: true

adapters_path = '../../lib/yuzakan/adapters'

Dir.each_child(File.expand_path(adapters_path, __dir__)) do |child|
  ext = File.extname(child)
  if %w[.rb .so].include?(ext)
    require_relative File.join(adapters_path, File.basename(child, ext))
  end
end

require_relative adapters_path

ADAPTERS = Yuzakan::Adapters.new
