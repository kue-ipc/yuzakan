# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Show do
  init_controller_spec
  let(:action_opts) { {attr_repository: attr_repository} }
  let(:format) { "application/json" }
  let(:action_params) { {id: "attr42"} }

  it "is successful" do
    response = action.call(params)
    expect(response.status).to eq 200
    expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json).to eq(attr_attributes.except(:id))
  end

  describe "admin" do
    let(:user) { User.new(**user_attributes, clearance_level: 5) }
    let(:client) { "127.0.0.1" }

    it "is successful" do
      response = action.call(params)
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        **attr_attributes.except(:id),
        mappings: mappings_attributes,
      })
    end

    describe "not existed" do
      let(:attr_repository) {
        instance_double(AttrRepository, **attr_repository_stubs, find_with_mappings_by_name: nil)
      }

      it "is failure" do
        response = action.call(params)
        expect(response.status).to eq 404
        expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json).to eq({
          code: 404,
          message: "Not Found",
        })
      end
    end
  end

  describe "no login session" do
    let(:session) { {uuid: uuid} }

    it "is error" do
      response = action.call(params)
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({code: 401, message: "Unauthorized"})
    end
  end
end
