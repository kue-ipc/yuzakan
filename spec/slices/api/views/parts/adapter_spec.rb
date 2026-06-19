# frozen_string_literal: true

RSpec.describe API::Views::Parts::Adapter do
  init_part_spec

  let(:value) { Hanami.app["adapter_repo"].get("test") }
  let(:simple_data) {
    {
      name: "test",
      label: "テスト",
    }
  }
  let(:expected_data) {
    {
      name: "test",
      label: "テスト",
      group: true,
      primary: true,
    }
  }

  shared_examples "full data" do
    it "to_h" do
      data = subject.to_h(**opts)
      expect(data.except(:params)).to eq(expected_data)
      expect(data[:params].keys).to contain_exactly(:schema, :default_values, :encrypted_keys)
    end

    it "to_json" do
      json = subject.to_json(**opts)
      data = JSON.parse(json, symbolize_names: true)
      expect(data.except(:params)).to eq(expected_data)
      expect(data[:params]).to eq({
        str: {title: "文字列", description: "詳細", type: "string", maxlength: 255},
        text: {title: "テキスト", type: "string"},
        int: {title: "整数", type: "integer"},
        limited_int: {type: "integer", min: 1, max: 100},
        float: {type: "number"},
        bool: {type: "boolean"},
        date: {type: "date"},
        time: {type: "time"},
        datetime: {type: "datetime"},
        required_str: {title: "必須文字列", type: "string", maxlength: 255, required: true},
        filled_str: {type: "string", minlength: 1, maxlength: 255},
        pattern_str: {type: "string", maxlength: 255, pattern: "^[a-z]*$"},
        fixed_str: {title: "固定値", type: "string", value: "abc", readonly: true},
        default_str: {title: "デフォルト値", type: "string", maxlength: 255, value: "xyz"},
        encrypted_str: {title: "暗号文字列", type: "string", maxlength: 255, encrypted: true},
        list: {title: "リスト", type: "string", list: [
          {value: "one", label: "ワン"},
          {value: "two", label: "ツー"},
          {value: "three", label: "スリー"},
        ]},
      })
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
