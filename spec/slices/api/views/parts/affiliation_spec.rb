# frozen_string_literal: true

RSpec.describe API::Views::Parts::Affiliation do
  init_part_spec

  let(:value) { affiliation }
  let(:full_data) {
    {
      name: value.name,
      label: value.label,
      note: value.note,
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
