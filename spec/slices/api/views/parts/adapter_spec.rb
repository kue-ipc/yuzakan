# frozen_string_literal: true

RSpec.describe API::Views::Parts::Adapter do
  init_part_spec

  let(:value) { Hanami.app["adapter_repo"].get("test") }
  let(:opts) { {} }

  shared_examples "full" do
    it "to_h" do
      data = subject.to_h(**opts)
      expect(data.except(:params)).to eq({
        name: "test",
        label: "テスト",
        group: true,
        primary: true,
      })
      expect(data[:params].keys).to contain_exactly(:schema)
    end

    it "to_json" do
      json = subject.to_json(**opts)
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
  end

  shared_examples "short" do
    it "to_h" do
      data = subject.to_h(**opts)
      expect(data).to eq({
        name: "test",
        label: "テスト",
      })
    end

    it "to_json" do
      json = subject.to_json(**opts)
      data = JSON.parse(json, symbolize_names: true)
      expect(data).to eq({
        name: "test",
        label: "テスト",
      })
    end
  end

  it_behaves_like "full"

  context "with restricted" do
    let(:opts) { {restricted: true} }

    it_behaves_like "short"
  end

  context "with simplified" do
    let(:opts) { {simplified: true} }

    it_behaves_like "short"
  end

  context "with restricted and simplified" do
    let(:opts) { {restricted: true, simplified: true} }

    it_behaves_like "short"
  end
end
