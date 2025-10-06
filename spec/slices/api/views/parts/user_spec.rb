# frozen_string_literal: true

RSpec.describe API::Views::Parts::User, :db do
  init_part_spec

  let(:value) {
    user = Hanami.app["repos.user_repo"].find(Factory[:member].user_id)
    Hanami.app["repos.user_repo"].get_with_affiliation_and_groups(user.name)
  }

  it_behaves_like "to_h with simple"
  it_behaves_like "to_json with simple"

  it "to_h" do
    data = subject.to_h
    expect(data).to eq({
      name: value.name,
      label: value.label,
      email: value.email,
      note: value.note,
      affiliation: value.affiliation&.name,
      group: value.group&.name,
      groups: value.members.map(&:group).map(&:name),
      clearance_level: 1,
      prohibited: false,
      deleted: false,
      deleted_at: nil,
    })
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq({
      name: value.name,
      label: value.label,
      email: value.email,
      note: value.note,
      affiliation: value.affiliation&.name,
      group: value.group&.name,
      groups: value.members.map(&:group).map(&:name),
      clearanceLevel: 1,
      prohibited: false,
      deleted: false,
      deletedAt: nil,
    })
  end
end
