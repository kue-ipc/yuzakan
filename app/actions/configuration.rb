# frozen_string_literal: true

require_relative "connection"

module Web
  module Configuration
    include Connection

    def self.included(action)
      if action.is_a?(Class)
        action.class_eval do
          before :configurate!
        end
      else
        action.define_singleton_method(:included, &method(:included))
      end
    end

    private def configurate!
      reply_uninitialized unless configurated?
    end

    private def configurated?
      !current_config.nil?
    end

    private def reply_uninitialized
      redirect_to Admin.routes.path(:new_config)
    end
  end
end
