# frozen_string_literal: true

RSpec.describe API::Views::Parts::Adapter do
  subject { described_class.new(value:) }

  let(:value) { Hanami.app["adapters"]["test"] }

  let(:test_params) {
    [
        {name: "str", label: "文字列", description: "詳細", type: "string", maxlength: 255},
        {name: "text", label: "テキスト", type: "string"},
        {name: "int", label: "整数", type: "integer"},
        {name: "float", label: "浮動小数点数", type: "float"},
        {name: "bool", label: "真偽値", type: "boolean"},
        {name: "date", label: "日付", type: "date"},
        {name: "time", label: "時間", type: "time"},
        {name: "datetime", label: "日時", type: "datetime"},
        {name: "required_str", label: "必須文字列", type: "string", required: true, maxlength: 255},
        {name: "pattern_str", label: "フォーマット付き文字列", type: "string", pattern: "[a-z]*", maxlength: 255},
        {name: "fixed_str", label: "固定文字列", type: "string", value: "abc"},
        {name: "list", label: "リスト", type: "string", list: [
          {name: "one", label: "ワン"},
          {name: "two", label: "ツー"},
          {name: "three", label: "スリー"},
        ],},
      ]
  }

  it "to_h" do
    expect(subject.to_h).to eq({
      name: "test",
      label: "テスト",
      group: true,
      primary: true,
      params: test_params,
    })
  end

  it "to_json" do
    json = JSON.parse(subject.to_json, symbolize_names: true)
    expect(json).to eq({
      name: "test",
      label: "テスト",
      group: true,
      primary: true,
      paramTypes: test_params,
    })
  end
end
