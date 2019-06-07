# frozen_string_literal: true

class ProviderRepository < Hanami::Repository
  def self.params
    %i[
      provider_string_params
      provider_integer_params
      provider_boolean_params
      provider_secret_params
    ]
  end

  associations do
    ProviderRepository.params.each do |param|
      has_many param
    end
  end

  # def authenticatables
  #   aggregate(*ProviderRepository.params)
  #     .where(authenticatable: true)
  #     .order { order.asc }
  #     .map_to(Provider)
  # end

  def last_order
    providers.order { order.desc }.first
  end

  def operational_all(operation)
    operation_ability = {
      create: :writable,
      read: :readable,
      update: :writable,
      delete: :writable,
      auth: :authenticatable,
      change_password: :password_changeable,
      lock: :lockable,
      unlcok: :lockable,
      locked?: :lockable,
    }
    ability = operation_ability[operation]
    raise "不明な操作です。#{operation}" unless ability

    aggregate(*ProviderRepository.params)
      .where(ability => true)
      .order { order.asc }
      .map_to(Provider)
  end




end
