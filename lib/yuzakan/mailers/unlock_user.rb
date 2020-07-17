module Mailers
  class UnlockUser
    include Hanami::Mailer

    from    '<from>'
    to      '<to>'
    subject 'Hello'
  end
end
