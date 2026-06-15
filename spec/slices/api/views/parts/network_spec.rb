# frozen_string_literal: true

RSpec.describe API::Views::Parts::Network do
  init_part_spec

  let(:value) { network }

  shared_examples "simple data" do
    it "to_h" do
      data = subject.to_h(**opts)
      expect(data).to eq({
        ip: "0.0.0.0/0",
      })
    end

    it "to_json" do
      json = subject.to_json(**opts)
      data = JSON.parse(json, symbolize_names: true)
      expect(data).to eq({
        ip: "0.0.0.0/0",
      })
    end
  end

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

  shared_examples "full data" do
    it "to_h" do
      data = subject.to_h(**opts)
      expect(data).to eq({
        ip: "0.0.0.0/0",
        clearance_level: 1,
        trusted: false,
      })
    end

    it "to_json" do
      json = subject.to_json(**opts)
      data = JSON.parse(json, symbolize_names: true)
      expect(data).to eq({
        ip: "0.0.0.0/0",
        clearanceLevel: 1,
        trusted: false,
      })
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
