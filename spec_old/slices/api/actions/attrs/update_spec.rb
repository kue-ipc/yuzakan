# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Update do
  init_controller_spec
  let(:action_opts) {
    {
      attr_repository: attr_repository,
      attr_mapping_repository: attr_mapping_repository,
      provider_repository: provider_repository,
    }
  }
  let(:format) { "application/json" }
  let(:action_params) {
    {
      id: "attr42",
      **attr_attributes.except(:id),
      mappings: attr_mappings_attributes,
    }
  }

  it "is failure" do
    response = action.call(params)
    expect(response[0]).to eq 403
    expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    expect(json).to eq({code: 403, message: "Forbidden"})
  end

  describe "admin" do
    let(:user) { User.new(**user_attributes, clearance_level: 5) }
    let(:client) { "127.0.0.1" }

    it "is successful" do
      response = action.call(params)
      expect(response[0]).to eq 200
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        **attr_attributes.except(:id),
        mappings: attr_mappings_attributes,
      })
    end

    it "is successful with different" do
      response = action.call({**params, name: "hoge", display_name: "ほげ"})
      expect(response[0]).to eq 200
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      expect(response[1]["Content-Location"]).to eq "/api/attrs/hoge"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        **attr_attributes.except(:id),
        mappings: attr_mappings_attributes,
      })
    end

    describe "not existed" do
      let(:attr_repository) {
        instance_double(AttrRepository, **attr_repository_stubs, find_with_mappings_by_name: nil)
      }

      it "is failure" do
        response = action.call(params)
        expect(response[0]).to eq 404
        expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({
          code: 404,
          message: "Not Found",
        })
      end
    end

    describe "existed name" do
      let(:attr_repository) { instance_double(AttrRepository, **attr_repository_stubs, exist_by_name?: true) }

      it "is successful" do
        response = action.call(params)
        expect(response[0]).to eq 200
        expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({
          **attr_attributes.except(:id),
          mappings: attr_mappings_attributes,
        })
      end

      it "is successful with diffrent only display_name" do
        response = action.call({**params, display_name: "ほげ"})
        expect(response[0]).to eq 200
        expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({
          **attr_attributes.except(:id),
          mappings: attr_mappings_attributes,
        })
      end

      it "is failure with different" do
        response = action.call({**params, name: "hoge", display_name: "ほげ"})
        expect(response[0]).to eq 422
        expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({
          code: 422,
          message: "Unprocessable Entity",
          errors: [{name: ["重複しています。"]}],
        })
      end
    end
  end

  describe "no login session" do
    let(:session) { {uuid: uuid} }

    it "is error" do
      response = action.call(params)
      expect(response[0]).to eq 401
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({code: 401, message: "Unauthorized"})
    end
  end
end
