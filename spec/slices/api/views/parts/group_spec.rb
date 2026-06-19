# frozen_string_literal: true

RSpec.describe API::Views::Parts::Group do
  init_part_spec

  let(:value) { group }
  let(:full_data) {
    {
      name: value.name,
      label: value.label,
      note: value.note,
      affiliation: value.affiliation&.name,
      services: value.services&.map(&:name),
      attrs: nil,
      basic: false,
      prohibited: false,
      deleted_at: nil,
      synced_at: nil,
    }
  }

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
