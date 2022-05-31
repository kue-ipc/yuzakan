class ProviderRepository < Hanami::Repository
  associations do
    has_many :provider_params
    has_many :attr_mappings
    has_many :attrs, throught: :attr_mappings
  end

  def ordered_all
    providers.order(:order).to_a
  end

  private def by_name(name)
    providers.where(name: name)
  end

  private def by_label(label)
    providers.where(label: label)
  end

  private def by_order(order)
    providers.where(order: order)
  end

  def find_by_name(name)
    by_name(name).one
  end

  def find_by_label(label)
    by_label(label).one
  end

  def exist_by_name?(name)
    by_name(name).exist?
  end

  def exist_by_label?(label)
    by_label(label).exist?
  end

  def exist_by_order?(order)
    by_order(order).exist?
  end

  def all_individual_password
    providers.where(individual_password: true).to_a
  end

  def find_with_params(id)
    aggregate(:provider_params).where(id: id).map_to(Provider).one
  end

  def find_with_params_by_name(name)
    aggregate(:provider_params).where(name: name).map_to(Provider).one
  end

  def add_param(provider, data)
    assoc(:provider_params, provider).add(data)
  end

  private def param_by_name(provider, param_name)
    assoc(:provider_params, provider).where(name: param_name)
  end

  def delete_param_by_name(provider, param_name)
    param_by_name(provider, param_name).delete
  end

  def last_order
    providers.order(:order).last&.fetch(:order).to_i
  end

  def ordered_all_with_adapter
    aggregate(:provider_params, attr_mappings: :attr).order(:order).map_to(Provider).to_a
  end

  def find_with_adapter(id)
    aggregate(:provider_params, attr_mappings: :attr).where(id: id).map_to(Provider).one
  end

  def find_with_adapter_by_name(name)
    aggregate(:provider_params, attr_mappings: :attr).where(name: name).map_to(Provider).one
  end

  def ordered_all_with_adapter_by_operation(operation)
    operation_ability =
      case operation
      when :user_create, :user_update, :user_delete
        {writable: true}
      when :user_read, :user_list, :user_seacrh
        {readable: true}
      when :user_auth
        {authenticatable: true}
      when :user_change_password, :user_generate_code
        {password_changeable: true, individual_password: false}
      when :user_lock, :user_unlock
        {lockable: true}
      when :group_read, :group_list, :member_list
        {group: true, readable: true}
      when :member_add, :member_remove
        {group: true, writable: true}
      else
        raise "不明な操作です。#{operation}"
      end

    ordered_all_with_adapter_by_ability(operation_ability)
  end

  def ordered_all_with_adapter_by_ability(ability)
    aggregate(:provider_params, attr_mappings: :attr).where(ability).order(:order).map_to(Provider).to_a
  end

  def first_google
    providers
      .where(adapter_name: 'google')
      .where(self_management: true)
      .order(:order)
      .first
  end

  def first_google_with_adapter
    aggregate(:provider_params, attr_mappings: :attr)
      .where(adapter_name: 'google')
      .where(self_management: true)
      .order(:order)
      .map_to(Provider)
      .first
  end
end
