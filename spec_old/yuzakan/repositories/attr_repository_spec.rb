# frozen_string_literal: true

RSpec.describe AttrRepository do
  let(:attr_repository) { described_class.new }

  before do
    @attr_hoge = attr_repository.create(name: "hoge", label: "ほげ", type: "string", order: 8)
    @attr_fuga = attr_repository.create(name: "fuga", label: "ふが", type: "integer", order: 32)
    @attr_piyo = attr_repository.create(name: "piyo", label: "ぴよ", type: "boolean", order: 16)
  end

  after do
    attr_repository.clear
  end

  it "ordered_all" do
    all = attr_repository.ordered_all
    expect(all).to be_instance_of Array
    expect(all.map(&:name)).to eq ["hoge", "piyo", "fuga"]
  end

  it "find_by_name" do
    expect(attr_repository.find_by_name("hoge")).to be_instance_of Attr
    expect(attr_repository.find_by_name("moe")).to be_nil
  end

  it "exist_by_name?" do
    expect(attr_repository.exist_by_name?("hoge")).to be true
    expect(attr_repository.exist_by_name?("moe")).to be false
  end

  it "last_order" do
    expect(attr_repository.last_order).to eq 32
    attr_repository.clear
    expect(attr_repository.last_order).to eq 0
  end

  describe "with mappings" do
    let(:mapping_repository) { MappingRepository.new }
    let(:service_repository) { ServiceRepository.new }

    before do
      @service_hoge = service_repository.create(name: "hoge", label: "ほげ", adapter: "dummy", order: 8)
      @service_fuga = service_repository.create(name: "fuga", label: "ふが", adapter: "dummy", order: 16)

      @mapping_hoge_hoge = mapping_repository.create(attr_id: @attr_hoge.id, service_id: @service_hoge.id,
        key: "hoge_hoge")
      @mapping_hoge_fuga = mapping_repository.create(attr_id: @attr_hoge.id, service_id: @service_fuga.id,
        key: "hoge_fuga", conversion: "e2j")
    end

    after do
      service_repository.clear
      mapping_repository.clear
    end

    it "ordered_all_with_mappings" do
      all = attr_repository.ordered_all_with_mappings
      expect(all).to be_instance_of Array
      expect(all.map(&:name)).to eq ["hoge", "piyo", "fuga"]
      expect(all.first.mappings.first.key).to eq "hoge_hoge"
    end

    it "find_with_mappings" do
      attr_with_mappings = attr_repository.find_with_mappings(@attr_hoge.id)
      expect(attr_with_mappings).to be_instance_of Attr
      expect(attr_with_mappings.name).to eq "hoge"
      expect(attr_with_mappings.mappings.first.key).to eq "hoge_hoge"
    end

    it "create_with_mappings" do
      attr_with_mappings = attr_repository.create_with_mappings(
        name: "moe", label: "もえ", type: "string", order: 40, hidden: false,
        mappings: [
          {service_id: @service_hoge.id, key: "moe_hoge"},
          {service_id: @service_fuga.id, key: "moe_fuga", conversion: "e2j"},
        ])
      expect(attr_with_mappings).to be_instance_of Attr
      expect(attr_with_mappings.name).to eq "moe"
      expect(attr_with_mappings.mappings.first.key).to eq "moe_hoge"
      expect(attr_repository.all.count).to eq 4
      expect(mapping_repository.all.count).to eq 4
    end

    it "add_mapping" do
      mapping = attr_repository.add_mapping(@attr_fuga, {service_id: @service_hoge.id, key: "fuga_hoge"})
      expect(mapping).to be_instance_of Mapping
      expect(mapping.key).to eq "fuga_hoge"
      expect(mapping_repository.all.count).to eq 3
    end

    it "delete_mapping_by_service_id" do
      delete_count = attr_repository.delete_mapping_by_service_id(@attr_hoge, @service_hoge.id)
      expect(delete_count).to eq 1
      expect(mapping_repository.all.count).to eq 1

      delete_count = attr_repository.delete_mapping_by_service_id(@attr_fuga, @service_hoge.id)
      expect(delete_count).to eq 0
      expect(mapping_repository.all.count).to eq 1
    end

    it "find_mapping_by_service_id" do
      mapping = attr_repository.find_mapping_by_service_id(@attr_hoge, @service_hoge.id)
      expect(mapping).to eq @mapping_hoge_hoge
    end
  end
end
