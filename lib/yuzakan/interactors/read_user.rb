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
  expose :userdata_list

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(params)
    @userdata = {name: params[:username], attrs: {}}
    @userdata_list = []

    providers = @provider_repository.ordered_all_with_adapter_by_operation(:read)
    providers.each do |provider|
      userdata = provider.read(params[:username])
      if userdata
        @userdata_list << {provider: provider, userdata: userdata} 
        @userdata[:display_name] ||= userdata[:display_name]
        @userdata[:email] ||= userdata[:email]
        @userdata[:attrs] = userdata[:attrs].merge(@userdata[:attrs])
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
