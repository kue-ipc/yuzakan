# frozen_string_literal: true

RSpec.describe API::Views::Parts::Adapter do
  init_part_spec

  let(:value) { Hanami.app["adapter_map"]["test"] }

  it "to_h" do
    data = subject.to_h
    expect(data.except(:params)).to eq({
      name: "test",
      label: "テスト",
      group: true,
      primary: true,
    })
    expect(data[:params].keys).to contain_exactly(:schema)
  end

  it "to_h with sipmle" do
    data = subject.to_h(simple: true)
    expect(data).to eq({
      name: "test",
      label: "テスト",
    })
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq({
      name: "test",
      label: "テスト",
      group: true,
      primary: true,
      params: {schema: {
        type: "object",
        properties: {
          str: {title: "文字列", description: "詳細", type: "string", maxLength: 255},
          text: {type: "string"},
          int: {type: "integer"},
          float: {type: "number"},
          bool: {type: "boolean"},
          date: {type: "date"},
          time: {type: "time"},
          datetime: {type: "datetime"},
          requiredStr: {type: "string", maxLength: 255},
          filledStr: {type: "string", minLength: 1, maxLength: 255},
          patternStr: {type: "string", maxLength: 255, pattern: "^[a-z]*$"},
          fixedStr: {type: "string", const: "abc"},
          defaultStr: {type: "string", maxLength: 255, default: "xyz"},
          encryptedStr: {type: "string", maxLength: 255},
          list: {type: "string", enum: ["one", "two", "three"]},
        },
        required: ["requiredStr"],
      }},
    })
  end

  it "to_json with simple" do
    data = JSON.parse(subject.to_json(simple: true), symbolize_names: true)
    expect(data).to eq({
      name: "test",
      label: "テスト",
    })
  end
end
