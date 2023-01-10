# frozen_string_literal: true

require_relative '../../spec_helper'

describe AttrRepository do
  let(:attr_repository) { AttrRepository.new }

  before do
    @attr_hoge = attr_repository.create(name: 'hoge', display_name: 'ほげ', type: 'string', order: 8)
    @attr_fuga = attr_repository.create(name: 'fuga', display_name: 'ふが', type: 'integer', order: 32)
    @attr_piyo = attr_repository.create(name: 'piyo', display_name: 'ぴよ', type: 'boolean', order: 16)
  end

  after do
    attr_repository.clear
  end

  it 'ordered_all' do
    all = attr_repository.ordered_all
    _(all).must_be_instance_of Array
    _(all.map(&:name)).must_equal ['hoge', 'piyo', 'fuga']
  end

  it 'find_by_name' do
    _(attr_repository.find_by_name('hoge')).must_be_instance_of Attr
    _(attr_repository.find_by_name('moe')).must_be_nil
  end

  it 'exist_by_name?' do
    _(attr_repository.exist_by_name?('hoge')).must_equal true
    _(attr_repository.exist_by_name?('moe')).must_equal false
  end

  it 'last_order' do
    _(attr_repository.last_order).must_equal 32
    attr_repository.clear
    _(attr_repository.last_order).must_equal 0
  end

  describe 'with mappings' do
    let(:attr_mapping_repository) { AttrMappingRepository.new }
    let(:provider_repository) { ProviderRepository.new }

    before do
      @provider_hoge = provider_repository.create(name: 'hoge', display_name: 'ほげ', adapter_name: 'dummy', order: 8)
      @provider_fuga = provider_repository.create(name: 'fuga', display_name: 'ふが', adapter_name: 'dummy', order: 16)

      @attr_mapping_hoge_hoge = attr_mapping_repository.create(attr_id: @attr_hoge.id, provider_id: @provider_hoge.id,
                                                               name: 'hoge_hoge')
      @attr_mapping_hoge_fuga = attr_mapping_repository.create(attr_id: @attr_hoge.id, provider_id: @provider_fuga.id,
                                                               name: 'hoge_fuga', conversion: 'e2j')
    end

    after do
      provider_repository.clear
      attr_mapping_repository.clear
    end

    it 'ordered_all_with_mappings' do
      all = attr_repository.ordered_all_with_mappings
      _(all).must_be_instance_of Array
      _(all.map(&:name)).must_equal ['hoge', 'piyo', 'fuga']
      _(all.first.attr_mappings.first.name).must_equal 'hoge_hoge'
    end

    it 'find_with_mappings' do
      attr_with_mappings = attr_repository.find_with_mappings(@attr_hoge.id)
      _(attr_with_mappings).must_be_instance_of Attr
      _(attr_with_mappings.name).must_equal 'hoge'
      _(attr_with_mappings.attr_mappings.first.name).must_equal 'hoge_hoge'
    end

    it 'create_with_mappings' do
      attr_with_mappings = attr_repository.create_with_mappings(
        name: 'moe', display_name: 'もえ', type: 'string', order: 40, hidden: false,
        attr_mappings: [
          {provider_id: @provider_hoge.id, name: 'moe_hoge'},
          {provider_id: @provider_fuga.id, name: 'moe_fuga', conversion: 'e2j'},
        ])
      _(attr_with_mappings).must_be_instance_of Attr
      _(attr_with_mappings.name).must_equal 'moe'
      _(attr_with_mappings.attr_mappings.first.name).must_equal 'moe_hoge'
      _(attr_repository.all.count).must_equal 4
      _(attr_mapping_repository.all.count).must_equal 4
    end

    it 'add_mapping' do
      attr_mapping = attr_repository.add_mapping(@attr_fuga, {provider_id: @provider_hoge.id, name: 'fuga_hoge'})
      _(attr_mapping).must_be_instance_of AttrMapping
      _(attr_mapping.name).must_equal 'fuga_hoge'
      _(attr_mapping_repository.all.count).must_equal 3
    end

    it 'delete_mapping_by_provider_id' do
      delete_count = attr_repository.delete_mapping_by_provider_id(@attr_hoge, @provider_hoge.id)
      _(delete_count).must_equal 1
      _(attr_mapping_repository.all.count).must_equal 1

      delete_count = attr_repository.delete_mapping_by_provider_id(@attr_fuga, @provider_hoge.id)
      _(delete_count).must_equal 0
      _(attr_mapping_repository.all.count).must_equal 1
    end

    it 'find_mapping_by_provider_id' do
      attr_mapping = attr_repository.find_mapping_by_provider_id(@attr_hoge, @provider_hoge.id)
      _(attr_mapping).must_equal @attr_mapping_hoge_hoge
    end
  end
end
