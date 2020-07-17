require 'erb'

module Mailers
  module Partial
    def partial(name)
      file_name = "_#{name}.txt.erb"
      erb_file =
        Hanami::Mailer.configuration.root / 'templates' / file_name
      ERB.new(erb_file.read, trim_mode: '%-', eoutvar: '_erbout_partial')
        .result(binding)
    end
  end
end
