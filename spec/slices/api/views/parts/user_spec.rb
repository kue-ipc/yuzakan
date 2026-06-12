# frozen_string_literal: true

RSpec.describe API::Views::Parts::User, :db do
  init_part_spec

  let(:value) {
    Hanami.app["repos.user_repo"].get_with_associations(Factory[:user].name)
  }

  shared_examples "to_h_and_to_json" do
    it "to_h with restricted" do
      data = subject.to_h(restricted: true)
      expect(data).to eq({
        name: value.name,
        label: value.label,
        email: value.email,
      })
    end

    it "to_json with restricted" do
      json = subject.to_json(restricted: true)
      data = JSON.parse(json, symbolize_names: true)
      expect(data).to eq({
        name: value.name,
        label: value.label,
        email: value.email,
      })
    end

    it "to_h" do
      data = subject.to_h
      services = value.managings.map do |managing|
        {name: managing.service.name, unmanageable: false, locked: false, mfa: false}
      end
      expect(data).to eq({
        name: value.name,
        label: value.label,
        email: value.email,
        note: value.note,
        affiliation: value.affiliation&.name,
        primary_group: value.group&.name,
        groups: value.member_groups.map(&:name),
        services:,
        attrs: nil,
        clearance_level: 1,
        prohibited: false,
        deleted_at: nil,
        synced_at: nil,
      })
    end

    it "to_json" do
      json = subject.to_json
      data = JSON.parse(json, symbolize_names: true)
      services = value.managings.map do |managing|
        {name: managing.service.name, unmanageable: false, locked: false, mfa: false}
      end
      expect(data).to eq({
        name: value.name,
        label: value.label,
        email: value.email,
        note: value.note,
        affiliation: value.affiliation&.name,
        primaryGroup: value.group&.name,
        groups: value.member_groups.map(&:name),
        services:,
        attrs: nil,
        clearanceLevel: 1,
        prohibited: false,
        deletedAt: nil,
        syncedAt: nil,
      })
    end
  end

  it_behaves_like "to_h_and_to_json"

  context "with member" do
    let(:value) {
      user = Hanami.app["repos.user_repo"].find(Factory[:member].user_id)
      Hanami.app["repos.user_repo"].get_with_associations(user.name)
    }

    it_behaves_like "to_h_and_to_json"
  end

  context "with service" do
    let(:value) {
      user = Hanami.app["repos.user_repo"].find(Factory[:managed_user].user_id)
      Hanami.app["repos.user_repo"].get_with_associations(user.name)
    }

    it_behaves_like "to_h_and_to_json"
  end
end
