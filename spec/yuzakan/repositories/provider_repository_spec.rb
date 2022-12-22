require_relative '../../spec_helper'

describe ProviderRepository do
  let(:provider_repository) { ProviderRepository.new }

  before do
    @provider_hoge = provider_repository.create(name: 'hoge', display_name: 'ほげ', adapter_name: 'test', order: 8)
    @provider_fuga = provider_repository.create(name: 'fuga', display_name: 'ふが', adapter_name: 'test', order: 32)
    @provider_piyo = provider_repository.create(name: 'piyo', display_name: 'ぴよ', adapter_name: 'test', order: 16)
  end

  after do
    provider_repository.clear
  end

  it 'ordered_all' do
    all = provider_repository.ordered_all
    _(all).must_be_instance_of Array
    _(all.map(&:name)).must_equal ['hoge', 'piyo', 'fuga']
  end

  it 'find_by_name' do
    _(provider_repository.find_by_name('hoge')).must_be_instance_of Provider
    _(provider_repository.find_by_name('moe')).must_be_nil
  end

  it 'exist_by_name?' do
    _(provider_repository.exist_by_name?('hoge')).must_equal true
    _(provider_repository.exist_by_name?('moe')).must_equal false
  end

  it 'last_order' do
    _(provider_repository.last_order).must_equal 32
    provider_repository.clear
    _(provider_repository.last_order).must_equal 0
  end

  describe 'with params' do
    let(:provider_param_repository) { ProviderParamRepository.new }

    before do
      @provider_param_hoge = provider_param_repository.create(provider_id: @provider_hoge.id, name: 'str',
                                                              value: Marshal.dump('ほげほげ'))
      @provider_param_fuga = provider_param_repository.create(provider_id: @provider_hoge.id, name: 'int',
                                                              value: Marshal.dump(42))
    end

    after do
      provider_param_repository.clear
    end

    it 'find_with_params' do
      provider_with_params = provider_repository.find_with_params(@provider_hoge.id)
      _(provider_with_params).must_be_instance_of Provider
      _(provider_with_params.name).must_equal 'hoge'
      _(provider_with_params.params[:str]).must_equal 'ほげほげ'
      _(provider_with_params.params[:int]).must_equal 42
    end

    it 'find_with_params_by_name' do
      provider_with_params = provider_repository.find_with_params_by_name('hoge')
      _(provider_with_params).must_be_instance_of Provider
      _(provider_with_params.name).must_equal 'hoge'
      _(provider_with_params.params[:str]).must_equal 'ほげほげ'
      _(provider_with_params.params[:int]).must_equal 42
    end

    it 'add_param' do
      provider_param = provider_repository.add_param(@provider_fuga, {name: 'str', value: Marshal.dump('ふがふが')})
      _(provider_param).must_be_instance_of ProviderParam
      _(provider_param.name).must_equal 'str'
      _(provider_param_repository.all.count).must_equal 3
    end

    it 'delete_param_by_name' do
      delete_count = provider_repository.delete_param_by_name(@provider_hoge, 'str')
      _(delete_count).must_equal 1
      _(provider_param_repository.all.count).must_equal 1

      delete_count = provider_repository.delete_param_by_name(@provider_fuga, 'str')
      _(delete_count).must_equal 0
      _(provider_param_repository.all.count).must_equal 1
    end

    describe 'with adapter' do
      # TODO
      # attr_mappings and attr
      
      # ordered_all_with_adapter
      # find_with_adapter
      # find_with_adapter_by_name
      # ordered_all_with_adapter_by_operation
    end
  end
end
