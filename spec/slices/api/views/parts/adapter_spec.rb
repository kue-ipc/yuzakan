# frozen_string_literal: true

RSpec.describe API::Views::Parts::Adapter do
  subject { described_class.new(value:) }

  let(:value) { Hanami.app["adapters"]["test"] }

  let(:test_params_schema) {
    {
      type: "object",
      properties: {
        str: {
          title: "文字列",
          description: "詳細",
          type: "string",
          max_length: 255,
        },
        text: {title: "テキスト", type: "string"},
        int: {title: "整数", type: "integer"},
        float: {title: "浮動小数点数", type: "number"},
        bool: {title: "真偽値", type: "boolean"},
        date: {title: "日付", type: "date"},
        time: {title: "時間", type: "time"},
        datetime: {title: "日時", type: "datetime"},
        required_str: {title: "必須文字列", type: "string", max_length: 255, min_length: 1},
        pattern_str: {title: "パターン", type: "string", pattern: "^[a-z]*$", max_length: 255},
        fixed_str: {title: "固定値", type: "string", const: "abc"},
        list: {
          title: "リスト",
          type: "string",
          enum: ["one", "two", "three"],
        },
      },
      required: ["required_str"],
    }
  }

  it "to_h" do
    expect(subject.to_h).to eq({
      name: "test",
      label: "テスト",
      group: true,
      primary: true,
      params: {schema: test_params_schema},
    })
  end

  it "to_json" do
    json = JSON.parse(subject.to_json, symbolize_names: true)
    expect(json).to eq({
      name: "test",
      label: "テスト",
      group: true,
      primary: true,
      params: test_params,
    })
  end
end
