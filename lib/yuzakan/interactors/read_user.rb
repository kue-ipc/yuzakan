require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

class ReadUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
    end
  end

  expose :userdata
  expose :provider_userdatas

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(params)
    @userdata = {username: params[:username], attrs: {}, groups: []}
    @provider_userdatas = []

    providers = @provider_repository.ordered_all_with_adapter_by_operation(:user_read)
    providers.each do |provider|
      userdata = provider.user_read(params[:username])
      if userdata
        @provider_userdatas << {provider: provider, userdata: userdata} 
        @userdata[:username] ||= userdata[:username]
        @userdata[:display_name] ||= userdata[:display_name]
        @userdata[:email] ||= userdata[:email]
        @userdata[:attrs] = userdata[:attrs].merge(@userdata[:attrs])
        @userdata[:primary_group] ||= userdata[:primary_group] if userdata[:primary_group]
        @userdata[:groups] |= userdata[:groups] if userdata[:groups]
      end
    rescue => e
      Hanami.logger.error e
      error("ユーザー情報の読み込み時にエラーが発生しました。(#{provider.label}")
      raise if Hanami.env == 'development'
    end
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end

    true
  end
end
