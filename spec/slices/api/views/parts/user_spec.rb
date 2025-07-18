# frozen_string_literal: true

RSpec.describe API::Views::Parts::User do
  init_part_spec

  let(:value) { user }

  it_behaves_like "to_h with simple"
  it_behaves_like "to_json with simple"

  it "to_h" do
    data = subject.to_h
    expect(data).to eq({
      name: value.name,
      label: value.label,
    })
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq({
      name: value.name,
      label: value.label,
      note: value.note,
    })
  end
end
