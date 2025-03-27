# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Index do
  init_controller_spec
  let(:action_opts) { {attr_repository: attr_repository} }
  let(:format) { "application/json" }

  it "is successful" do
    response = action.call(params)
    expect(response.status).to eq 200
    expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect_json = attrs_attributes
      .sort_by { |data| data[:name] }
      .sort_by { |data| data[:order] }
      .map { |data| data.except(:id) }
    expect(json).to eq expect_json
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
