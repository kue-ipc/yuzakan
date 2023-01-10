# frozen_string_literal: true

module Mailers
  class AdminNotify
    include Hanami::Mailer

    from    '<from>'
    to      '<to>'
    subject 'Hello'
  end
end
