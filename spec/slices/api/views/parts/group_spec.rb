# frozen_string_literal: true

RSpec.describe API::Views::Parts::Group, :db do
  init_part_spec

  let(:value) {
    Hanami.app["repos.group_repo"].get_with_associations(Factory[:group].name)
  }

  shared_examples "to_h_and_to_json" do
    it_behaves_like "to_h with restricted"
    it_behaves_like "to_json with restricted"

    it "to_h" do
      data = subject.to_h
      services = value.managings.map do |managing|
        {name: managing.service.name, unmanageable: false}
      end
      expect(data).to eq({
        name: value.name,
        label: value.label,
        note: value.note,
        affiliation: value.affiliation&.name,
        services:,
        attrs: nil,
        basic: false,
        prohibited: false,
        deleted_at: nil,
        synced_at: nil,
      })
    end

    it "to_json" do
      json = subject.to_json
      data = JSON.parse(json, symbolize_names: true)
      services = value.managings.map do |managing|
        {name: managing.service.name, unmanageable: false}
      end
      expect(data).to eq({
        name: value.name,
        label: value.label,
        note: value.note,
        affiliation: value.affiliation&.name,
        services:,
        attrs: nil,
        basic: false,
        prohibited: false,
        deletedAt: nil,
        syncedAt: nil,
      })
    end
  end

  it_behaves_like "to_h_and_to_json"

  context "with service" do
    let(:value) {
      group = Hanami.app["repos.group_repo"].find(Factory[:managed_group].group_id)
      Hanami.app["repos.group_repo"].get_with_associations(group.name)
    }

    it_behaves_like "to_h_and_to_json"
  end
end
