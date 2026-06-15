# frozen_string_literal: true

RSpec.describe API::Views::Parts::User, :db do
  init_part_spec

  let(:value) { user }

  shared_examples "short data" do
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
  end

  shared_examples "full data" do
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
