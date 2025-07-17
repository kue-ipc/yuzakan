# frozen_string_literal: true

RSpec.describe API::Views::Parts::Dictionary, :db do
  init_part_spec

  let(:value) {
    Hanami.app["repos.dictionary_repo"].get_with_terms(Factory[:term].dictionary.name)
  }

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

  it "to_h with simple" do
    data = subject.to_h(simple: true)
    expect(data).to eq({
      name: value.name,
      label: value.label,
    })
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

  it "to_json with simple" do
    json = subject.to_json(simple: true)
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq({
      name: value.name,
      label: value.label,
    })
  end
end
