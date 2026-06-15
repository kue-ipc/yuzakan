# frozen_string_literal: true

RSpec.describe API::Views::Parts::Dictionary, :db do
  init_part_spec

  let(:value) { dictionary }

  shared_examples "full data" do
    it "to_h" do
      data = subject.to_h
      expect(data.except(:terms)).to eq({
        name: value.name,
        label: value.label,
        description: value.description,
      })
      expcetd_terms = value.terms.map do |term|
        {
          term: term.term,
          description: term.description,
        }
      end
      expect(data[:terms]).to match_array(expcetd_terms)
    end

    it "to_json" do
      json = subject.to_json
      data = JSON.parse(json, symbolize_names: true)
      expect(data.except(:terms)).to eq({
        name: value.name,
        label: value.label,
        description: value.description,
      })
      expcetd_terms = value.terms.map do |term|
        {
          term: term.term,
          description: term.description,
        }
      end
      expect(data[:terms]).to match_array(expcetd_terms)
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
