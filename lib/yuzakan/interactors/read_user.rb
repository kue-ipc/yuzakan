class ReadUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:username).filled(:str?, max_size?: 255)
    end
  end

  expose :userdata
  expose :provider_userdatas

  def initialize(provider_repository: ProviderRepository.new, providers: nil)
    @providers = providers || provider_repository.operational_all_with_adapter(:read).to_a
  end

  def call(params)
    username = params[:username]
    @userdata = {
      name: username,
      display_name: nil,
      email: nil,
      attrs: {},
      count: 0,
    }
    @provider_userdatas = @providers.to_h do |provider|
      userdata = provider.read(username)
      if userdata
        @userdata[:count] += 1
        @userdata[:display_name] ||= userdata[:display_name]
        @userdata[:email] ||= userdata[:email]
        @userdata[:attrs].merge(userdata[:attrs]) do |_key, self_val, other_val|
          if self_val.nil?
            other_val
          else
            self_val
          end
        end
      end
      [provider.name, userdata]
    rescue => e
      Hanami.logger.error e
      error!("ユーザー情報の読み込み時にエラーが発生しました。: #{e.message}")
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
