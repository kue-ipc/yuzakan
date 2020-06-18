# frozen_string_literal: true

class ProviderRepository < Hanami::Repository
  def self.params
    @params ||= %i[
      provider_boolean_params
      provider_string_params
      provider_text_params
      provider_integer_params
      provider_float_params
      provider_datetime_params
      provider_date_params
      provider_time_params
      provider_file_params
    ].freeze
  end

  associations do
    has_many :provider_attr_mappings
    ProviderRepository.params.each do |param|
      has_many param
    end
  end

  def find_with_params(id)
    aggregate(*ProviderRepository.params)
      .where(id: id)
      .map_to(Provider)
      .one
  end

  def find_by_name_with_params(name)
    aggregate(*ProviderRepository.params)
      .where(name: name)
      .map_to(Provider)
      .one
  end

  def find_by_name(name)
    providers.where(name: name).one
  end

  def find_by_display_name(display_name)
    providers.where(display_name: display_name).one
  end

  def last_order
    providers.order { order.desc }.first
  end

  def operational_all_with_params(operation)
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
      list: :readable,
    }
    ability = operation_ability[operation]
    raise "不明な操作です。#{operation}" unless ability

    aggregate(*ProviderRepository.params)
      .where(ability => true)
      .order { order.asc }
      .map_to(Provider)
  end
end
