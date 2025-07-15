# frozen_string_literal: true

RSpec.describe API::Views::Parts::Affiliation do
  init_part_spec

  let(:value) { Factory.structs[:affiliation] }

  it "to_h" do
    hash = subject.to_h
    expect(hash).to eq({
      name: value.name,
      label: value.label,
      note: value.note,
    })
  end

  it "to_json" do
    json = JSON.parse(subject.to_json, symbolize_names: true)
    expect(json).to eq({
      name: value.name,
      label: value.label,
      note: value.note,
    })
  end
end
