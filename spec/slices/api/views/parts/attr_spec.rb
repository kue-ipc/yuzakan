# frozen_string_literal: true

# NOTE: get a combined entry from repo, so :db is required

RSpec.describe API::Views::Parts::Attr, :db do
  init_part_spec

  let(:value) {
    Hanami.app["repos.attr_repo"].get_with_mappings(Factory[:mapping].attr.name)
  }

  it "to_h" do
    data = subject.to_h
    expect(data.except(:mappings)).to eq({
      name: value.name,
      label: value.label,
      description: value.description,
      category: value.category,
      type: value.type,
      order: value.order,
      hidden: value.hidden,
      readonly: value.readonly,
      code: value.code,
    })
    expcetd_mappings = value.mappings.map do |mapping|
      {
        key: mapping.key,
        type: mapping.type,
        params: mapping.params,
        service: mapping.service.name,
      }
    end
    expect(data[:mappings]).to match_array(expcetd_mappings)
  end

  it "to_h with simple" do
    data = subject.to_h(simple: true)
    expect(data).to eq({
      name: value.name,
      label: value.label,
    })
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data.except(:mappings)).to eq({
      name: value.name,
      label: value.label,
      description: value.description,
      category: value.category,
      type: value.type,
      order: value.order,
      hidden: value.hidden,
      readonly: value.readonly,
      code: value.code,
    })
    expcetd_mappings = value.mappings.map do |mapping|
      {
        key: mapping.key,
        type: mapping.type,
        params: mapping.params,
        service: mapping.service.name,
      }
    end
    expect(data[:mappings]).to match_array(expcetd_mappings)
  end

  it "to_json with simple" do
    json = subject.to_json(simple: true)
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq({
      name: value.name,
      label: value.label,
    })
  end
end
