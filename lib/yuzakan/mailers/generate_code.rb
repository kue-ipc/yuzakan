module Mailers
  class GenerateCode
    include Hanami::Mailer

    from    '<from>'
    to      '<to>'
    subject 'Hello'
  end
end
