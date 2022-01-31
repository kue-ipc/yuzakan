require_relative './connection'

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
      return reply_uninitialized unless configurated?
      return reply_maintenance if maintenance?
    end

    private def configurated?
      !current_config.nil?
    end

    private def maintenance?
      current_config.maintenance
    end

    private def reply_uninitialized
      redirect_to Web.routes.path(:uninitialized)
    end

    private def reply_maintenance
      redirect_to Web.routes.path(:maintenance)
    end
  end
end
