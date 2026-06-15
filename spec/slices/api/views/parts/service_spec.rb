# frozen_string_literal: true

RSpec.describe API::Views::Parts::Service do
  init_part_spec

  let(:value) { service }

  shared_examples "full data" do
    it "to_h" do
      data = subject.to_h(**opts)
      expect(data).to eq({
        name: value.name,
        label: value.label,
        description: value.description,
        order: 1,
        adapter: "dummy",
        params: {},
        readable: false, # default
        writable: false, # default
        authenticatable: false, # default
        password_changeable: false, # default
        lockable: false, # default
        group: false, # default
        individual_password: false, # default
        self_management: false, # default
        synced_at: nil,
      })
    end

    it "to_json" do
      json = subject.to_json(**opts)
      data = JSON.parse(json, symbolize_names: true)
      expect(data).to eq({
        name: value.name,
        label: value.label,
        description: value.description,
        order: 1,
        adapter: "dummy",
        params: {},
        readable: false, # default
        writable: false, # default
        authenticatable: false, # default
        passwordChangeable: false, # default
        lockable: false, # default
        group: false, # default
        individualPassword: false, # default
        selfManagement: false, # default
        syncedAt: nil,
      })
    end
  end

  it_behaves_like "full data"

  context "with restricted" do
    let(:opts) { {restricted: true} }

    it_behaves_like "simple data"
  end

  context "with simplified" do
    let(:opts) { {simplified: true} }

    it_behaves_like "simple data"
  end

  context "with restricted and simplified" do
    let(:opts) { {restricted: true, simplified: true} }

    it_behaves_like "simple data"
  end
end
