# frozen_string_literal: true

RSpec.describe API::Views::Parts::Attr do
  init_part_spec

  before do
    allow(attr).to receive_messages(mappings: [mapping])
  end

  let(:value) { attr }
  let(:expected_data) {
    {
      name: value.name,
      label: value.label,
      description: value.description,
      category: value.category,
      type: value.type,
      order: value.order,
      hidden: value.hidden,
      readonly: value.readonly,
      code: value.code,
    }
  }
  let(:limited_data) {
    {
      name: value.name,
      label: value.label,
      category: value.category,
      type: value.type,
    }
  }
  let(:expcetd_mappings) {
    value.mappings.map do |mapping|
      {
        key: mapping.key,
        type: mapping.type,
        params: mapping.params,
        service: mapping.service.name,
      }
    end
  }

  shared_examples "limited data" do
    it "to_h" do
      data = subject.to_h(**opts)
      expect(data).to eq(limited_data)
    end

    it "to_json" do
      json = subject.to_json(**opts)
      data = JSON.parse(json, symbolize_names: true)
      expect(data).to eq(limited_data)
    end
  end

  shared_examples "full data" do
    it "to_h" do
      data = subject.to_h(**opts)
      expect(data.except(:mappings)).to eq(expected_data)
      expect(data[:mappings]).to match_array(expcetd_mappings)
    end

    it "to_json" do
      json = subject.to_json(**opts)
      data = JSON.parse(json, symbolize_names: true)
      expect(data.except(:mappings)).to eq(expected_data)
      expect(data[:mappings]).to match_array(expcetd_mappings)
    end
  end

  it_behaves_like "full data"

  context "with restricted" do
    let(:opts) { {restricted: true} }

    it_behaves_like "limited data"
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
