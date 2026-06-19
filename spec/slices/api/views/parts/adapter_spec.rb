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
      expect(data[:params].keys).to contain_exactly(:schema)
    end

    it "to_json" do
      json = subject.to_json(**opts)
      data = JSON.parse(json, symbolize_names: true)
      expect(data.except(:params)).to eq(expected_data)
      expect(data[:params]).to eq({
        schema: {
          type: "object",
          properties: {
            str: {title: "文字列", description: "詳細", type: "string", maxlength: 255},
            text: {type: "string"},
            int: {type: "integer"},
            float: {type: "number"},
            bool: {type: "boolean"},
            date: {type: "date"},
            time: {type: "time"},
            datetime: {type: "datetime"},
            required_str: {type: "string", maxlength: 255},
            filled_str: {type: "string", minlength: 1, maxlength: 255},
            pattern_str: {type: "string", maxlength: 255, pattern: "^[a-z]*$"},
            fixed_str: {type: "string", const: "abc"},
            default_str: {type: "string", maxlength: 255, default: "xyz"},
            encrypted_str: {type: "string", maxlength: 255},
            list: {type: "string", enum: ["one", "two", "three"]},
          },
          required: ["required_str"],
        },
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
