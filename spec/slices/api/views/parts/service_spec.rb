# frozen_string_literal: true

RSpec.describe API::Views::Parts::Service, :db do
  init_part_spec

  let(:value) { service }

  it_behaves_like "to_h with simple"
  it_behaves_like "to_json with simple"

  it "to_h" do
    data = subject.to_h
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
    })
  end

  it "to_json" do
    json = subject.to_json
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
    })
  end
end
