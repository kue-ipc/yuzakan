module Mailers
  class CreateUser
    include Hanami::Mailer

    from    '<from>'
    to      '<to>'
    subject 'Hello'
  end
end
