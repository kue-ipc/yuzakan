# frozen_string_literal: true

RSpec.describe ServiceRepository do
  let(:service_repository) { described_class.new }

  before do
    @service_hoge = service_repository.create(name: "hoge", label: "ほげ", adapter: "test", order: 8)
    @service_fuga = service_repository.create(name: "fuga", label: "ふが", adapter: "test", order: 32)
    @service_piyo = service_repository.create(name: "piyo", label: "ぴよ", adapter: "test", order: 16)
  end

  after do
    service_repository.clear
  end

  it "ordered_all" do
    all = service_repository.ordered_all
    expect(all).to be_instance_of Array
    expect(all.map(&:name)).to eq ["hoge", "piyo", "fuga"]
  end

  it "find_by_name" do
    expect(service_repository.find_by_name("hoge")).to be_instance_of Service
    expect(service_repository.find_by_name("moe")).to be_nil
  end

  it "exist_by_name?" do
    expect(service_repository.exist_by_name?("hoge")).to be true
    expect(service_repository.exist_by_name?("moe")).to be false
  end

  it "last_order" do
    expect(service_repository.last_order).to eq 32
    service_repository.clear
    expect(service_repository.last_order).to eq 0
  end

  describe "with params" do
    let(:adapter_param_repository) { AdapterParamRepository.new }

    before do
      @adapter_param_hoge = adapter_param_repository.create(service_id: @service_hoge.id, name: "str",
        value: Marshal.dump("ほげほげ"))
      @adapter_param_fuga = adapter_param_repository.create(service_id: @service_hoge.id, name: "int",
        value: Marshal.dump(42))
    end

    after do
      adapter_param_repository.clear
    end

    it "find_with_params" do
      service_with_params = service_repository.find_with_params(@service_hoge.id)
      expect(service_with_params).to be_instance_of Service
      expect(service_with_params.name).to eq "hoge"
      expect(service_with_params.params[:str]).to eq "ほげほげ"
      expect(service_with_params.params[:int]).to eq 42
    end

    it "find_with_params_by_name" do
      service_with_params = service_repository.find_with_params_by_name("hoge")
      expect(service_with_params).to be_instance_of Service
      expect(service_with_params.name).to eq "hoge"
      expect(service_with_params.params[:str]).to eq "ほげほげ"
      expect(service_with_params.params[:int]).to eq 42
    end

    it "add_param" do
      adapter_param = service_repository.add_param(@service_fuga, {name: "str", value: Marshal.dump("ふがふが")})
      expect(adapter_param).to be_instance_of AdapterParam
      expect(adapter_param.name).to eq "str"
      expect(adapter_param_repository.all.count).to eq 3
    end

    it "delete_param_by_name" do
      delete_count = service_repository.delete_param_by_name(@service_hoge, "str")
      expect(delete_count).to eq 1
      expect(adapter_param_repository.all.count).to eq 1

      delete_count = service_repository.delete_param_by_name(@service_fuga, "str")
      expect(delete_count).to eq 0
      expect(adapter_param_repository.all.count).to eq 1
    end
  end
end
