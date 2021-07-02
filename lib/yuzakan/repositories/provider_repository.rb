class ProviderRepository < Hanami::Repository
  PARAMS = %i[
    provider_boolean_params
    provider_string_params
    provider_text_params
    provider_integer_params
  ].freeze

  def self.params
    @params ||= %i[
      provider_boolean_params
      provider_string_params
      provider_text_params
      provider_integer_params
    ].freeze
  end

  associations do
    has_many :attr_mappings
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

  def by_name(name)
    providers.where(name: name)
  end

  def find_by_display_name(display_name)
    providers.where(display_name: display_name).one
  end

  def individual_password
    providers.where(individual_password: true)
  end

  def last_order
    providers.order { order.desc }.first
  end

  def operational_all_with_params(operation)
    operation_ability =
      case operation
      when :create, :update, :delete
        {writable: true}
      when :read, :list
        {readable: true}
      when :auth
        {authenticatable: true}
      when :change_password
        {password_changeable: true, individual_password: false}
      when :lock, :unlock, :locked?
        {lockable: true, individual_password: false}
      else
        raise "不明な操作です。#{operation}"
      end

    aggregate(*ProviderRepository.params)
      .where(operation_ability)
      .order { order.asc }
      .map_to(Provider)
  end

  def first_google
    providers
      .where(adapter_name: 'google')
      .where(self_management: true)
      .order { order.asc }
      .first
  end

  def first_google_with_params
    aggregate(*ProviderRepository.params)
      .where(adapter_name: 'google')
      .where(self_management: true)
      .order { order.asc }
      .map_to(Provider)
      .first
  end
end
