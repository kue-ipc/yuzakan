# frozen_string_literal: true

require "securerandom"

module Yuzakan
  module Actions
    module Connection
      include Deps[
        "repos.activity_log_repo",
        "repos.config_repo",
        "repos.network_repo",
        "repos.user_repo",
      ]

      def self.included(action)
        action.extend(ClassMethods)
        action.class_eval do
          before :check_session!
          before :connect!
          after :done!
          # expose :current_config
          # expose :current_user
          # expose :current_level
        end
      end

      module ClassMethods
        def security_level(level = nil)
          if level
            @level = level
          else
            @level || default_security_level
          end
        end

        def default_security_level
          1
        end
      end

      private def connect!
        session[:updated_at] = current_time if current_config && current_user

        @log_info = {
          uuid: uuid,
          client: client,
          username: current_user&.name,
          action: self.class.name,
          method: request.request_method,
          path: request.path,
        }
        Hanami.logger.info(@log_info)
      end

      private def done!
        activity_log_repo.create(**@log_info, status: response[0])
      end

      private def current_config
        @current_config ||= config_repo.current
      end

      private def uuid
        @uuid ||= session[:uuid] ||= SecureRandom.uuid
      end

      private def client
        request.ip
      end

      private def current_user
        @current_user ||= session[:user_id] && user_repo.find(session[:user_id])
      end

      private def current_network
        @current_network ||= FindNetwork.new(network_repository: network_repo).call({ip: client}).network
      end

      private def current_level
        @current_level ||= [
          current_user&.clearance_level || 0,
          current_network&.clearance_level || 0,
        ].min
      end

      private def current_time
        @current_time ||= Time.now
      end

      def security_level
        self.class.security_level
      end

      private def check_session!
        return if session[:user_id].nil?
        return unless session_timeout?

        session[:user_id] = nil
        session[:created_at] = nil
        session[:updated_at] = nil
        @current_user = nil

        reply_session_timeout
      end

      private def session_timeout?
        return true if session[:updated_at].nil?

        timeout = current_config&.session_timeout || 3600
        timeout.zero? || current_time - session[:updated_at] > timeout
      end

      private def reply_session_timeout
        flash[:warn] = "セッションがタイムアウトしました。"
        redirect_to Web.routes.path(:root)
      end
    end
  end
end
