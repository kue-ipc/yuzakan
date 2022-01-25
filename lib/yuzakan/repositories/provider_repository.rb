class ProviderRepository < Hanami::Repository
  associations do
    has_many :provider_params
    has_many :attr_mappings
    has_many :attrs, throught: :attr_mappings
  end

  def all
    providers.order(:order).to_a
  end

  def all_with_adapter
    aggregate(:provider_params, attr_mappings: :attr)
      .order(:order)
      .map_to(Provider)
  end

  def find_with_adapter(id)
    aggregate(:provider_params, attr_mappings: :attr)
      .where(id: id)
      .map_to(Provider)
      .one
  end

  def find_by_name_with_adapter(name)
    aggregate(:provider_params, attr_mappings: :attr)
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

  def operational_all_with_adapter(operation)
    operation_ability =
      case operation
      when :create, :update, :delete
        {writable: true}
      when :read, :list, :seacrh
        {readable: true}
      when :auth
        {authenticatable: true}
      when :change_password, :generate_code
        {password_changeable: true, individual_password: false}
      when :lock, :unlock
        {lockable: true}
      else
        raise "不明な操作です。#{operation}"
      end

    aggregate(:provider_params, attr_mappings: :attr)
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

  def first_google_with_adapter
    aggregate(:provider_params, attr_mappings: :attr)
      .where(adapter_name: 'google')
      .where(self_management: true)
      .order { order.asc }
      .map_to(Provider)
      .first
  end
end
