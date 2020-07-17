module Mailers
  class DestroyUser
    include Hanami::Mailer

    from    '<from>'
    to      '<to>'
    subject 'Hello'
  end
end
