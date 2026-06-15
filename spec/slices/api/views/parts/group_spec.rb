# frozen_string_literal: true

RSpec.describe API::Views::Parts::Group, :db do
  init_part_spec

  let(:value) { group }

  shared_examples "full data" do
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
