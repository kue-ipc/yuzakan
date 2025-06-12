# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Destroy do
  init_controller_spec
  let(:action_opts) { {attr_repository: attr_repository} }
  let(:format) { "application/json" }
  let(:action_params) { {id: "attr42"} }
  # let(:attr_params) {
  #   {
  #     name: 'attr1', display_name: '属性①', type: 'string', order: 8, hidden: false,
  #     mappings: [
  #       {provider: 'provider1', name: 'attr1_1', conversion: nil},
  #       {provider: 'provider2', name: 'attr1_2', conversion: 'e2j'},
  #     ],
  #   }
  # }
  # let(:attr_attributes) {
  #   mappings = attr_params[:mappings].map do |mapping|
  #     {**mapping.except(:provider), provider: {name: mapping[:provider]}}
  #   end
  #   {**attr_params.except(:mappings), mappings: mappings}
  # }
  # let(:attr_with_mappings) { Attr.new(id: 42, **attr_attributes) }
  # let(:attr_without_mappings) { Attr.new(id: 42, **attr_attributes.except(:mappings)) }
  # let(:attr_repository) {
  #   instance_double('AttrRepository', find_with_mappings_by_name: attr_with_mappings, delete: attr_without_mappings)
  # }

  it "is failure" do
    response = action.call(params)
    expect(response.status).to eq 403
    expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json).to eq({code: 403, message: "Forbidden"})
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

    describe "not existend" do
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
