# frozen_string_literal: true

RSpec.describe API::Views::Parts::Adapter do
  subject { described_class.new(value:) }

  let(:value) { Hanami.app["adapters"]["test"] }

  it "to_h" do
    hash = subject.to_h
    expect(hash.except(:params)).to eq({
      name: "test",
      label: "テスト",
      group: true,
      primary: true,
    })
    expect(hash[:params].keys).to contain_exactly(:schema)
  end

  it "to_json" do
    json = JSON.parse(subject.to_json, symbolize_names: true)
    expect(json).to eq({
      name: "test",
      label: "テスト",
      group: true,
      primary: true,
      params: {schema: {
        type: "object",
        properties: {
          str: {title: "文字列",description: "詳細", type: "string", maxLength: 255},
          text: {type: "string"},
          int: {type: "integer"},
          float: {type: "number"},
          bool: {type: "boolean"},
          date: {type: "date"},
          time: {type: "time"},
          datetime: {type: "datetime"},
          requiredStr: {type: "string", maxLength: 255},
          filledStr: {type: "string", minLength: 1, maxLength: 255},
          patternStr: {type: "string", pattern: "^[a-z]*$", maxLength: 255},
          fixedStr: {type: "string", const: "abc"},
          defaultStr: {type: "string", defalut: "xyz", maxLength: 255},
          encryptedStr: {type: "string", maxLength: 255},
          list: {type: "string", enum: ["one", "two", "three"]},
        },
        required: ["requiredStr"],
      }},
    })
  end
end
