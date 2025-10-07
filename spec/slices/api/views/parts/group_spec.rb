# frozen_string_literal: true

RSpec.describe API::Views::Parts::Group, :db do
  init_part_spec

  let(:value) {
    Hanami.app["repos.group_repo"].get_with_affiliation(Factory[:group].name)
  }

  it_behaves_like "to_h with restrict"
  it_behaves_like "to_json with restrict"

  it "to_h" do
    data = subject.to_h
    expect(data).to eq({
      name: value.name,
      label: value.label,
      note: value.note,
      basic: value.basic,
      prohibited: value.prohibited,
      deleted: value.deleted,
      deleted_at: value.deleted_at,
      affiliation: value.affiliation&.name,
    })
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq({
      name: value.name,
      label: value.label,
      note: value.note,
      basic: value.basic,
      prohibited: value.prohibited,
      deleted: value.deleted,
      deletedAt: value.deleted_at,
      affiliation: value.affiliation&.name,
    })
  end
end
