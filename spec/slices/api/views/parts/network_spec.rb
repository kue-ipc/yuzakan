# frozen_string_literal: true

RSpec.describe API::Views::Parts::Network do
  init_part_spec

  let(:value) { network }
  let(:full_data) {
    {
      ip: "0.0.0.0/0",
      clearance_level: 1,
      trusted: false,
    }
  }
  let(:simple_data) {
    {
      ip: "0.0.0.0/0",
    }
  }

  shared_examples "limited data" do
    it "to_h" do
      data = subject.to_h(**opts)
      expect(data).to eq({})
    end

    it "to_json" do
      json = subject.to_json(**opts)
      data = JSON.parse(json, symbolize_names: true)
      expect(data).to eq({})
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

    it_behaves_like "limited data"
  end
end
