# frozen_string_literal: true

RSpec.describe ProviderRepository do
  let(:provider_repository) { described_class.new }

  before do
    @provider_hoge = provider_repository.create(name: "hoge", label: "ほげ", adapter: "test", order: 8)
    @provider_fuga = provider_repository.create(name: "fuga", label: "ふが", adapter: "test", order: 32)
    @provider_piyo = provider_repository.create(name: "piyo", label: "ぴよ", adapter: "test", order: 16)
  end

  after do
    provider_repository.clear
  end

  it "ordered_all" do
    all = provider_repository.ordered_all
    expect(all).to be_instance_of Array
    expect(all.map(&:name)).to eq ["hoge", "piyo", "fuga"]
  end

  it "find_by_name" do
    expect(provider_repository.find_by_name("hoge")).to be_instance_of Provider
    expect(provider_repository.find_by_name("moe")).to be_nil
  end

  it "exist_by_name?" do
    expect(provider_repository.exist_by_name?("hoge")).to be true
    expect(provider_repository.exist_by_name?("moe")).to be false
  end

  it "last_order" do
    expect(provider_repository.last_order).to eq 32
    provider_repository.clear
    expect(provider_repository.last_order).to eq 0
  end

  describe "with params" do
    let(:adapter_param_repository) { AdapterParamRepository.new }

    before do
      @adapter_param_hoge = adapter_param_repository.create(provider_id: @provider_hoge.id, name: "str",
        value: Marshal.dump("ほげほげ"))
      @adapter_param_fuga = adapter_param_repository.create(provider_id: @provider_hoge.id, name: "int",
        value: Marshal.dump(42))
    end

    after do
      adapter_param_repository.clear
    end

    it "find_with_params" do
      provider_with_params = provider_repository.find_with_params(@provider_hoge.id)
      expect(provider_with_params).to be_instance_of Provider
      expect(provider_with_params.name).to eq "hoge"
      expect(provider_with_params.params[:str]).to eq "ほげほげ"
      expect(provider_with_params.params[:int]).to eq 42
    end

    it "find_with_params_by_name" do
      provider_with_params = provider_repository.find_with_params_by_name("hoge")
      expect(provider_with_params).to be_instance_of Provider
      expect(provider_with_params.name).to eq "hoge"
      expect(provider_with_params.params[:str]).to eq "ほげほげ"
      expect(provider_with_params.params[:int]).to eq 42
    end

    it "add_param" do
      adapter_param = provider_repository.add_param(@provider_fuga, {name: "str", value: Marshal.dump("ふがふが")})
      expect(adapter_param).to be_instance_of AdapterParam
      expect(adapter_param.name).to eq "str"
      expect(adapter_param_repository.all.count).to eq 3
    end

    it "delete_param_by_name" do
      delete_count = provider_repository.delete_param_by_name(@provider_hoge, "str")
      expect(delete_count).to eq 1
      expect(adapter_param_repository.all.count).to eq 1

      delete_count = provider_repository.delete_param_by_name(@provider_fuga, "str")
      expect(delete_count).to eq 0
      expect(adapter_param_repository.all.count).to eq 1
    end
  end
end
